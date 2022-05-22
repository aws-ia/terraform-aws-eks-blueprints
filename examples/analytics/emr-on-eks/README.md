# EMR on EKS

This example deploys the following resources

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with public endpoint (for demo purpose only) with one managed node group
- Deploys Metrics server, Cluster Autoscaler, Prometheus and EMR on EKS Addon
- Creates Amazon managed Prometheus and configures Prometheus addon to remote write metrics to AMP

## Prerequisites:

Ensure that you have installed the following tools on your machine.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

_Note: Currently Amazon Prometheus supported only in selected regions. Please see this [userguide](https://docs.aws.amazon.com/prometheus/latest/userguide/what-is-Amazon-Managed-Service-Prometheus.html) for supported regions._

## Step 1: Deploy EKS Clusters with EMR on EKS feature

Clone the repository

```
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

Navigate into one of the example directories and run `terraform init`

```
cd examples/analytics/emr-on-eks
terraform init
```

Set AWS_REGION and Run Terraform plan to verify the resources created by this execution.

```
export AWS_REGION="<enter-your-region>"
terraform plan
```

Deploy the pattern

```
terraform apply
```

Enter `yes` to apply.

## Step 3: Verify the resources

Let’s verify the resources created by Step 4.

Verify the Amazon EKS Cluster and Amazon Managed service for Prometheus

```shell script
aws eks describe-cluster --name aws001-preprod-test-eks

aws amp list-workspaces --alias amp-ws-aws001-preprod-test-eks
```

```shell script
Verify EMR on EKS Namespaces emr-data-team-a and emr-data-team-b and Pod status for Prometheus, Vertical Pod Autoscaler, Metrics Server and Cluster Autoscaler.

aws eks --region <ENTER_YOUR_REGION> update-kubeconfig --name aws001-preprod-test-eks # Creates k8s config file to authenticate with EKS Cluster

kubectl get nodes # Output shows the EKS Managed Node group nodes

kubectl get ns | grep emr-data-team # Output shows emr-data-team-a and emr-data-team-b namespaces for data teams

kubectl get pods --namespace=prometheus # Output shows Prometheus server and Node exporter pods

kubectl get pods --namespace=vpa  # Output shows Vertical Pod Autoscaler pods

kubectl get pods --namespace=kube-system | grep  metrics-server # Output shows Metric Server pod

kubectl get pods --namespace=kube-system | grep  cluster-autoscaler # Output shows Cluster Autoscaler pod
```

## Step 4: Create EMR Virtual Cluster for EKS

We are using AWS CLI to create EMR on EKS Clusters. You can leverage Terraform Module once the [EMR on EKS TF provider](https://github.com/hashicorp/terraform-provider-aws/pull/20003) is available.

```shell script
vi examples/analytics/emr-on-eks/examples/create_emr_virtual_cluster_for_eks.sh
```

Update the following variables.

Extract the cluster_name as **EKS_CLUSTER_ID** from Terraform Outputs (**Step 1**)
**EMR_ON_EKS_NAMESPACE** is same as what you passed from **Step 1**

    EKS_CLUSTER_ID='aws001-preprod-test-eks'
    EMR_ON_EKS_NAMESPACE='emr-data-team-a'

Execute the shell script to create virtual cluster

```shell script
cd examples/analytics/emr-on-eks/examples/
./create_emr_virtual_cluster_for_eks.sh
```

## Step 5: Execute Spark job on EMR Virtual Cluster

Execute the Spark job using the below shell script.

This script requires two input parameters.

    EMR_VIRTUAL_CLUSTER_ID=$1  # EMR Cluster ID e.g., aws001-preprod-test-eks-emr-data-team-a
    S3_BUCKET=$2               # S3 bucket for storing the scripts and spark output data e.g., s3://<bucket-name>

```shell script
cd examples/analytics/emr-on-eks/examples/spark-execute/
./5-spark-job-with-AMP-AMG.sh aws001-preprod-test-eks-emr-data-team-a <ENTER_S3_BUCKET_NAME>
```

Verify the job execution

```shell script
kubectl get pods --namespace=emr-data-team-a -w
```

## Step 5: Cleanup

### Delete EMR Virtual Cluster for EKS

```shell script
cd examples/analytics/emr-on-eks/examples/
./delete_emr_virtual_cluster_for_eks.sh
```

## Additional examples

### Node Placements example

Add these to `applicationConfiguration`.`properties`

          "spark.kubernetes.node.selector.topology.kubernetes.io/zone":"<availability zone>",
          "spark.kubernetes.node.selector.node.kubernetes.io/instance-type":"<instance type>"

### JDBC example

In this example we are connecting to mysql db, so mariadb-connector-java.jar needs to be passed with --jars option
https://aws.github.io/aws-emr-containers-best-practices/metastore-integrations/docs/hive-metastore/

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

```shell script
Error: local-exec provisioner error \
with module.eks-blueprints.module.emr_on_eks["data_team_b"].null_resource.update_trust_policy,\
 on .terraform/modules/eks-blueprints/modules/emr-on-eks/main.tf line 105, in resource "null_resource" \
 "update_trust_policy":│ 105: provisioner "local-exec" {│ │ Error running command 'set -e│ │ aws emr-containers update-role-trust-policy \
 │ --cluster-name aws001-preprod-test-eks \│ --namespace emr-data-team-b \│ --role-name aws001-preprod-test-eks-emr-eks-data-team-b
```

##### Solution :

- emr-containers not present in cli version 2.0.41 Python/3.7.4. For more [details](https://github.com/aws/aws-cli/issues/6162)
  This is fixed in version 2.0.54.
- Action: aws cli version should be updated to 2.0.54 or later : Execute `pip install --upgrade awscliv2 `
