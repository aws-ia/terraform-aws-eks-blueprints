# Apache Airflow add-on

This document describes the details of the best practices for building and deploying Self-managed **Highly Scalable Apache Airflow cluster on Kubernetes(Amazon EKS) Cluster**.
Alternatively, Amazon also provides a fully managed Apache Airflow service(MWAA). Please see this [example]( https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/managed-workflow-apache-airflow) if you are looking to build Amazon MWAA.

Apache Airflow is used for the scheduling and orchestration of data pipelines or workflows.
Orchestration of data pipelines refers to the sequencing, coordination, scheduling, and managing complex data pipelines from diverse sources.
A workflow is represented as a [DAG](https://airflow.apache.org/docs/apache-airflow/stable/concepts/dags.html) (a Directed Acyclic Graph), and contains individual pieces of work called [Tasks](https://airflow.apache.org/docs/apache-airflow/stable/concepts/tasks.html), arranged with dependencies and data flows taken into account.

## Production considerations for running Apache Airflow on EKS

### Airflow Metadata Database
It is advised to set up an external database for the Airflow metastore. The default Helm chart deploys a Postgres database running in a container but this should be used only for development.
Apache Airflow recommends to use MySQL or Postgres. This deployment configures the highly available Amazon RDS Postgres database as external database.

### PgBouncer for Amazon Postgres RDS
Airflow can open a lot of database connections due to its distributed nature and using a connection pooler can significantly reduce the number of open connections on the database.
This deployment enables the PgBouncer for Postgres

### Webserver Secret Key
You should set a static webserver secret key when deploying with this chart as it will help ensure your Airflow components only restart when necessary.
This deployment creates Kubernetes secret for Webserver Secret Key and applies to Airflow

### Managing DAG Files with GitHub and EFS
It's recommended to Mounting DAGs using Git-Sync sidecar with Persistence enabled.
Developers can create a repo to store the DAGs and configure to sync with Airflow servers.
This deployment provisions EFS(Amazon Elastic File System) through Persistent Volume Claim with an access mode of ReadWriteMany.
The Airflow scheduler pod will sync DAGs from a git repository onto the PVC every configured number of seconds.
The other pods will read the synced DAGs.

GitSync is configured with a sample repo with this example. This can be replaced with your internal GitHub repo

### Managing Log Files with S3 with IRSA
Airflow writes logs for tasks in a way that allows you to see the logs for each task separately in the Airflow UI.
Core Airflow implements writing and serving logs locally. However, you can also write logs to remote services via community providers, or write your own loggers.
This example configures S3 bucket to store the Airflow logs. IAM roles for server account(IRSA) is configured for Airflow pods to access this S3 bucket.

### Airflow StatsD Metrics
This example configures to send the metrics to an existing StatsD to Prometheus endpoint. This can be configured to send it to external StatsD instance

### Airflow Executors (Celery Vs Kubernetes)
This deployment uses Kubernetes Executor. With KubernetesExecutor, each task runs in its own pod.
The pod is created when the task is queued, and terminates when the task completes.
With KubernetesExecutor, the workers (pods) talk directly to the same Postgres backend as the Scheduler and can to a large degree take on the labor of task monitoring.

* KubernetesExecutor can work well when your tasks are not very uniform with respect to resource requirements or images.
* Each task on the Kubernetes executor gets its own pod, which allows you to pass an executor_config in your task params. This lets you assign resources at the task level by passing an executor_config. e.g, the first task may be a sensor that only requires a few resources, but the downstream tasks have to run on your GPU node pool with a higher CPU request. See the code snippet below
* Since each task is a pod, it is managed independently of the code deploys. This is great for longer running tasks or environments with a lot of users, as users can push new code without fear of interrupting that task.
* This makes the *k8s executor the most fault-tolerant* option, as running tasks won’t be affected when code is pushed
* In contrast to CeleryExecutor, KubernetesExecutor does not require additional components such as Redis, but does require access to Kubernetes cluster.
* Pod monitoring can be done with native Kubernetes tools
* A Kubernetes watcher is a thread that can subscribe to every change that occurs in Kubernetes’ database. It is alerted when pods start, run, end, and fail. By monitoring this stream, the KubernetesExecutor can discover that the worker crashed and correctly report the task as failed

### Airflow Schedulers
The Airflow scheduler monitors all tasks and DAGs, then triggers the task instances once their dependencies are complete.
Ths deployment uses *HA scheduler* with two replicas to take advantage of the existing metadata database.

### Accessing Airflow Web UI
This deployment example uses internet facing Load Balancer to easily access the WebUI however it's not recommended for Production.
You can modify the `values.yaml` to set the Load Balancer to `internal` and upload certificate to use HTTPS.
Ensure access to the WebUI using internal domain and network.


Checkout the [examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/analytics/airflow-on-eks) of deploying and using Apache Airflow on Amazon EKS.

## Usage

The [Apache Airflow](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/analytics/airflow-on-eks) can be deployed by enabling the add-on via the following.

```hcl
  enable_airflow = true
```

For production workloads, you can use this [example](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/analytics/airflow-on-eks) with custom Helm Config.

```hcl
    enable_airflow = true
    airflow_helm_config = {
      name             = "airflow"
      chart            = "airflow"
      repository       = "https://airflow.apache.org"
      version          = "1.6.0"
      namespace        = module.airflow_irsa.namespace
      create_namespace = false
      timeout          = 360
      description      = "Apache Airflow v2 Helm chart deployment configuration"
      # Check the example for `values.yaml` file
      values = [templatefile("${path.module}/values.yaml", {
        # Airflow Postgres RDS Config
        airflow_db_user = "airflow"
        airflow_db_name = module.db.db_instance_name
        airflow_db_host = element(split(":", module.db.db_instance_endpoint), 0)
        # S3 bucket config for Logs
        s3_bucket_name          = aws_s3_bucket.this.id
        webserver_secret_name   = local.airflow_webserver_secret_name
        airflow_service_account = local.airflow_service_account
      })]

      set_sensitive = [
        {
          name  = "data.metadataConnection.pass"
          value = data.aws_secretsmanager_secret_version.postgres.secret_string
        }
      ]
    }
```

Once deployed, you will be able to see the deployment status

```shell
kubectl get deployment -n airflow

NAME                READY   UP-TO-DATE   AVAILABLE   AGE
airflow-pgbouncer   1/1     1            1           77m
airflow-scheduler   2/2     2            2           77m
airflow-statsd      1/1     1            1           77m
airflow-triggerer   1/1     1            1           77m
airflow-webserver   2/2     2            2           77m

```
