# EMR on EKS

This example deploys the following resources

- Creates EKS Cluster Control plane with public endpoint (for demo purpose only) with two managed node groups
- Deploys Metrics server with HA, Cluster Autoscaler, Prometheus, VPA, CoreDNS Autoscaler
- EMR on EKS Teams and EMR Virtual cluster for `emr-data-team-a`
- Creates Amazon managed Prometheus Endpoint and configures Prometheus Server addon with remote write configuration to Amazon Managed Prometheus

## Prerequisites:

Ensure that you have installed the following tools on your machine.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

_Note: Currently Amazon Managed Prometheus supported only in selected regions. Please see this [userguide](https://docs.aws.amazon.com/prometheus/latest/userguide/what-is-Amazon-Managed-Service-Prometheus.html) for supported regions._

## Deploy EKS Clusters with EMR on EKS feature

Clone the repository

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

Navigate into one of the example directories and run `terraform init`

```sh
cd examples/analytics/emr-on-eks
terraform init
```

Set AWS_REGION and Run Terraform plan to verify the resources created by this execution.

```sh
export AWS_REGION="<enter-your-region>"
terraform plan
```

**Deploy the pattern**

```sh
terraform apply
```

Enter `yes` to apply.

## Verify the resources

Let’s verify the resources created by Step 4.

Verify the Amazon EKS Cluster and Amazon Managed service for Prometheus

```sh
aws eks describe-cluster --name emr-on-eks

aws amp list-workspaces --alias amp-ws-emr-on-eks
```

```sh
Verify EMR on EKS Namespaces emr-data-team-a and emr-data-team-b and Pod status for Prometheus, Vertical Pod Autoscaler, Metrics Server and Cluster Autoscaler.

aws eks --region <ENTER_YOUR_REGION> update-kubeconfig --name emr-on-eks # Creates k8s config file to authenticate with EKS Cluster

kubectl get nodes # Output shows the EKS Managed Node group nodes

kubectl get ns | grep emr-data-team # Output shows emr-data-team-a and emr-data-team-b namespaces for data teams

kubectl get pods --namespace=prometheus # Output shows Prometheus server and Node exporter pods

kubectl get pods --namespace=vpa  # Output shows Vertical Pod Autoscaler pods

kubectl get pods --namespace=kube-system | grep  metrics-server # Output shows Metric Server pod

kubectl get pods --namespace=kube-system | grep  cluster-autoscaler # Output shows Cluster Autoscaler pod
```

## Execute Spark job on EMR Virtual Cluster

Execute the Spark job using the below shell script.

This script requires three input parameters which can be extracted from `terraform apply` output values

    EMR_VIRTUAL_CLUSTER_ID=$1     # Terraform output variable is emrcontainers_virtual_cluster_id
    S3_BUCKET=$2                  # This script requires s3 bucket as input parameter e.g., s3://<bucket-name>
    EMR_JOB_EXECUTION_ROLE_ARN=$3 # Terraform output variable is emr_on_eks_role_arn

```sh
cd examples/analytics/emr-on-eks/examples/spark-execute/

./emr-eks-spark-amp-amg.sh "<ENTER_EMR_VIRTUAL_CLUSTER_ID>" "s3://<ENTER-YOUR-BUCKET-NAME>" "<EMR_JOB_EXECUTION_ROLE_ARN>"
```

Verify the job execution

```sh
kubectl get pods --namespace=emr-data-team-a -w
```

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```

## Additional examples

### Node Placements example

Add these to `applicationConfiguration`.`properties`

    "spark.kubernetes.node.selector.topology.kubernetes.io/zone":"<availability zone>",
    "spark.kubernetes.node.selector.node.kubernetes.io/instance-type":"<instance type>"

### JDBC example
In this example we are connecting to mysql db, so mariadb-connector-java.jar needs to be passed with --jars option

      "sparkSubmitJobDriver": {
      "entryPoint": "s3://<s3 prefix>/hivejdbc.py",
       "sparkSubmitParameters": "--jars s3://<s3 prefix>/mariadb-connector-java.jar
       --conf spark.hadoop.javax.jdo.option.ConnectionDriverName=org.mariadb.jdbc.Driver
       --conf spark.hadoop.javax.jdo.option.ConnectionUserName=<connection-user-name>
       --conf spark.hadoop.javax.jdo.option.ConnectionPassword=<connection-password>
       --conf spark.hadoop.javax.jdo.option.ConnectionURL=<JDBC-Connection-string>
       --conf spark.driver.cores=5
       --conf spark.executor.memory=20G
       --conf spark.driver.memory=15G
       --conf spark.executor.cores=6"
    }

### Storage
Spark supports using volumes to spill data during shuffles and other operations.
To use a volume as local storage, the volume’s name should starts with spark-local-dir-,
for example:

      --conf spark.kubernetes.driver.volumes.[VolumeType].spark-local-dir-[VolumeName].mount.path=<mount path>
      --conf spark.kubernetes.driver.volumes.[VolumeType].spark-local-dir-[VolumeName].mount.readOnly=false

Specifically, you can use persistent volume claims if the jobs require large shuffle and sorting operations in executors.

      spark.kubernetes.executor.volumes.persistentVolumeClaim.spark-local-dir-1.options.claimName=OnDemand
      spark.kubernetes.executor.volumes.persistentVolumeClaim.spark-local-dir-1.options.storageClass=gp
      spark.kubernetes.executor.volumes.persistentVolumeClaim.spark-local-dir-1.options.sizeLimit=500Gi

      spark.kubernetes.executor.volumes.persistentVolumeClaim.spark-local-dir-1.mount.path=/data
      spark.kubernetes.executor.volumes.persistentVolumeClaim.spark-local-dir-1.mount.readOnly=false

## Debugging
##### Issue1: Error: local-exec provisioner error

```sh
Error: local-exec provisioner error \
with module.eks-blueprints.module.emr_on_eks["data_team_b"].null_resource.update_trust_policy,\
 on .terraform/modules/eks-blueprints/modules/emr-on-eks/main.tf line 105, in resource "null_resource" \
 "update_trust_policy":│ 105: provisioner "local-exec" {│ │ Error running command 'set -e│ │ aws emr-containers update-role-trust-policy \
 │ --cluster-name emr-on-eks \│ --namespace emr-data-team-b \│ --role-name emr-on-eks-emr-eks-data-team-b
```

##### Solution :

- emr-containers not present in cli version 2.0.41 Python/3.7.4. For more [details](https://github.com/aws/aws-cli/issues/6162)
  This is fixed in version 2.0.54.
- Action: aws cli version should be updated to 2.0.54 or later : Execute `pip install --upgrade awscliv2 `
