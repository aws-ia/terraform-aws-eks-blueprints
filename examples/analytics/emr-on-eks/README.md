# EMR on EKS Deployment and Test

This example deploys the following resources

 - Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
 - Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
 - Creates EKS Cluster Control plane with public endpoint (for demo purpose only) with one managed node group
 - Deploys Metrics server, Cluster Autoscaler, Prometheus and EMR on EKS Addon
 - Creates Amazon managed Prometheus and configures Prometheus addon to remote write metrics to AMP

## Prerequisites:

Ensure that you have installed the following tools on your machine.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Step1: Deploy EKS Clusters with EMR on EKS feature

Clone the repository

```
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

Navigate into one of the example directories and run `terraform init`

```
cd examples/analytics/emr-on-eks
terraform init
```

Run Terraform plan to verify the resources created by this execution.

```
export AWS_REGION="eu-west-1"   # Select your own region
terraform plan

```

Deploy the pattern

```
terraform apply
```

Enter `yes` to apply.

## Step2: Create EMR Virtual Cluster for EKS

We are using AWS CLI to create EMR on EKS Clusters. You can leverage Terraform Module once the [EMR on EKS TF provider](https://github.com/hashicorp/terraform-provider-aws/pull/20003) is available.

```shell script
vi examples/analytics/emr-on-eks/examples/create_emr_virtual_cluster_for_eks.sh
```

Update the following variables.

Extract the cluster_name as **EKS_CLUSTER_ID** from Terraform Outputs (**Step1**)
**EMR_ON_EKS_NAMESPACE** is same as what you passed from **Step1**

    EKS_CLUSTER_ID='aws001-preprod-test-eks'
    EMR_ON_EKS_NAMESPACE='emr-data-team-a'

Execute the shell script to create virtual cluster

```shell script
cd examples/analytics/emr-on-eks/examples/
./create_emr_virtual_cluster_for_eks.sh
```

## Step3: Execute Spark job on EMR Virtual Cluster

Open and edit the `5-spark-job-with-AMP-AMG.sh` file

```shell script
vi examples/analytics/emr-on-eks/examples/spark-execute/5-spark-job-with-AMP-AMG.sh
```

Update the following variables. Extract the emr_on_eks_role_id as **EMR_ROLE_ID** and cluster_name as **EKS_CLUSTER_ID** from Terraform Outputs (**Step1**)

    EMR_ROLE_ID="aws001-preprod-test-EMRonEKSExecution"                     # Replace EMR IAM role with your ID
    EKS_CLUSTER_ID='aws001-preprod-test-eks'                                # Replace cluster id with your id
    S3_BUCKET='s3://<enter-pre-created-bucket-name>'                        # Create your own s3 bucket and replace this value
    CW_LOG_GROUP='/emr-on-eks-logs/emr-data-team-a'                         # Create your own s3 bucket and replace this value

Execute Sample PySpark Job.

```shell script
cd examples/analytics/emr-on-eks/examples/spark-execute/
./5-spark-job-with-AMP-AMG.sh
```

Verify the job is running in EMR under Virtual Clusters. Also, query JOB resource in EKS Cluster.

## Step4: Cleanup

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


<!--- BEGIN_TF_DOCS --->
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: MIT-0

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-eks-accelerator-for-terraform"></a> [aws-eks-accelerator-for-terraform](#module\_aws-eks-accelerator-for-terraform) | github.com/aws-samples/aws-eks-accelerator-for-terraform | n/a |
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | v3.2.0 |
| <a name="module_kubernetes-addons"></a> [kubernetes-addons](#module\_kubernetes-addons) | github.com/aws-samples/aws-eks-accelerator-for-terraform//modules/kubernetes-addons | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

No inputs.

## Outputs

No outputs.

<!--- END_TF_DOCS --->
