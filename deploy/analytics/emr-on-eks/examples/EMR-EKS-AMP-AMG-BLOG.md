# EMR on EKS Deployment

This example deploys the following resources

 - Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
 - Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
 - Creates EKS Cluster Control plane with public endpoint (for demo purpose only) with one managed node group
 - Deploys Metrics server, Cluster Autoscaler, Prometheus and EMR on EKS Addon
 - Creates Amazon managed Prometheus and configures Prometheus addon to remote write metrics to AMP

## Prerequisites


Before you build the whole infrastructure, you will need to meet the following prerequisites.

* An AWS Account
* _AWS CLI _ (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* _Terraform 1.0.1 _ (https://learn.hashicorp.com/tutorials/terraform/install-cli)
* kubectl - _Kubernetes CLI_ (https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

### Step1: Clone Github Repo

Clone `aws-eks-accelerator-for-terraform` repo and change to `emr-on-eks` directory

```sh
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git

cd aws-eks-accelerator-for-terraform/deploy/analytics/emr-on-eks
```

### Step2: Deploy EKS Cluster with EMR on EKS Resources

- Run Terraform init to intialize the modules

```sh
terraform init
```

- Run Terraform plan to verify the resources created by this execution.

```sh
export AWS_REGION="eu-west-1"   # Select your own region
terraform plan
```

- Run Terraform Apply to deploy the solution.

```
terraform apply --auto-approve
```

### Step3: Verify the resources created by Terraform Apply

Let’s verify the resources

* Login to AWS console and verify the VPC, three Private Subnets and three Public Subnets, Internet gateway and single NAT Gateway created with the prefix of aws001-prerpod-test-
* Open the EKS service page from the AWS console to verify the EKS cluster(aws001-preprod-test-eks) with one Managed node group with an instance type of m5.xlarge.
* Also, select the workloads dropdown under the workloads tab in EKS cluster page to verify the Prometheus Server pods under prometheus namespace, EMR on EKS Namespaces emr-data-team-a and emr-data-team-b, Vertical Pod Autoscaler pods under vpa-ns and Metrics Server & Cluster Autoscaler under kube-system namespace
* This deployment also creates a new Amazon Managed Prometheus workspace and configures community Prometheus Server add-on to *remote write metrics*.

### Step4: Create EMR Virtual Cluster

Navigate to the directory below and execute create_emr_virtual_cluster_for_eks.sh script. This command should take a few seconds to create an EMR Virtual cluster
```sh
cd ~/aws-eks-accelerator-for-terraform/deploy/analytics/emr-on-eks/examples

./create_emr_virtual_cluster_for_eks.sh aws001-preprod-test-eks-emr-data-team-a
```

This script uses EMR_VIRTUAL_CLUSTER_ID, EKS_CLUSTER_ID and EMR_ON_EKS_NAMESPACE as inputs to create an EMR Virtual Cluster. This script also creates a CloudWatch log group to write Spark Job Driver and Executor logs to CloudWatch Logs.

```sh
#!/bin/bash

EKS_CLUSTER_ID='aws001-preprod-test-eks'
EMR_ON_EKS_NAMESPACE='emr-data-team-a'

export VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?name=='${EKS_CLUSTER_ID}' && state=='RUNNING'].id" --output text)

# CREATE EMR VIRTUAL CLUSTER
if [[ $VIRTUAL_CLUSTER_ID = "" ]]; then
  echo "Creating new EMR Virtual Cluster"

    aws emr-containers create-virtual-cluster \
      --name $EKS_CLUSTER_ID \
      --container-provider '{
        "id": "'"$EKS_CLUSTER_ID"'",
        "type": "EKS",
        "info": {
          "eksInfo": {
              "namespace": "'"$EMR_ON_EKS_NAMESPACE"'"
          }
      }
  }'
```

### Step5: Execute the Spark Job

Navigate to the below directory and execute the shell script by providing EMR_VIRTUAL_CLUSTER_ID and S3_BUCKET names as input parameters. Please note that you need to _create an S3 Bucket_ (https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html) in the AWS account and provide the bucket's name before running this command.

```shell script
cd ~/aws-eks-accelerator-for-terraform/deploy/analytics/emr-on-eks/examples/spark-execute

./5-spark-job-with-AMP-AMG.sh \
    aws001-preprod-test-eks-emr-data-team-a \
    s3://<enter-yourbucket-name>
```

Please check the script below for more details

```sh
#!/bin/bash

# INPUT VARIABLES
EMR_ON_EKS_ROLE_ID="aws001-preprod-test-emr-eks-data-team-a"       # Replace EMR IAM role with your ID
EKS_CLUSTER_ID='aws001-preprod-test-eks'                           # Replace cluster id with your id
EMR_ON_EKS_NAMESPACE='emr-data-team-a'                             # Replace namespace with your namespace
JOB_NAME='pi'  

# FIND ROLE ARN and EMR VIRTUAL CLUSTER ID
EMR_ROLE_ARN=$(aws iam get-role --role-name $EMR_ON_EKS_ROLE_ID --query Role.Arn --output text)
VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?name=='${EKS_CLUSTER_ID}' && state=='RUNNING'].id" --output text)

# Execute Spark job
if [[ $VIRTUAL_CLUSTER_ID != "" ]]; then
  echo "Found Cluster $EKS_CLUSTER_ID; Executing the Spark job now..."
  aws emr-containers start-job-run \
    --virtual-cluster-id $VIRTUAL_CLUSTER_ID \
    --name $JOB_NAME \
    --execution-role-arn $EMR_ROLE_ARN \
    --release-label emr-6.3.0-latest \
    --job-driver '{
      "sparkSubmitJobDriver": {
        "entryPoint": "local:///usr/lib/spark/examples/src/main/python/pi.py",
        "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
      }
    }'
else
  echo "Cluster is not in running state $EKS_CLUSTER_ID"
fi

```

### Step6: Monitor Spark Submit

Login to AWS EMR Console, select the EMR Virtual Cluster and verify the job status. This should show the status as *Completed* in a few minutes, and the Spark Job execution results dataset will write to the S3 bucket under the OUTPUT folder.
