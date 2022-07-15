#!/bin/bash

if [ $# -eq 0 ];
then
  echo "$0: Missing arguments ENTER_EMR_EMR_VIRTUAL_CLUSTER_ID and EMR_JOB_EXECUTION_ROLE_ARN"
  echo "USAGE: ./basic-pyspark-job '<ENTER_EMR_EMR_VIRTUAL_CLUSTER_ID>' '<EMR_JOB_EXECUTION_ROLE_ARN>'"
  exit 1
elif [ $# -gt 3 ];
then
  echo "$0: Too many arguments: $@"
  echo "Usage example-> ./basic-pyspark-job '<ENTER_EMR_EMR_VIRTUAL_CLUSTER_ID>' '<EMR_JOB_EXECUTION_ROLE_ARN>'"
  exit 1
else
  echo "We got some argument(s)"
  echo "==========================="
  echo "Number of arguments.: $#"
  echo "List of arguments...: $@"
  echo "Arg #1..............: $1"
  echo "Arg #2..............: $2"
  echo "==========================="
fi

#--------------------------------------------
# INPUT VARIABLES
#--------------------------------------------
EMR_EMR_VIRTUAL_CLUSTER_ID=$1 # Terraform output variable is `emrcontainers_virtual_cluster_id`
EMR_JOB_EXECUTION_ROLE_ARN=$2 # Terraform output variable is emr_on_eks_role_arn
JOB_NAME='pi'
EMR_EKS_RELEASE_LABEL='emr-6.5.0-latest'

#--------------------------------------------
# DERIVED VARIABLES
#--------------------------------------------
EMR_VIRTUAL_CLUSTER_NAME=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?id=='${EMR_EMR_VIRTUAL_CLUSTER_ID}' && state=='RUNNING'].name" --output text)

# Execute Spark job
if [[ $EMR_VIRTUAL_CLUSTER_ID != "" ]]; then
  echo "Found Cluster $EMR_VIRTUAL_CLUSTER_NAME; Executing the Spark job now..."
  aws emr-containers start-job-run \
    --virtual-cluster-id $EMR_VIRTUAL_CLUSTER_ID \
    --name $JOB_NAME \
    --execution-role-arn $EMR_JOB_EXECUTION_ROLE_ARN \
    --release-label $EMR_EKS_RELEASE_LABEL \
    --job-driver '{
      "sparkSubmitJobDriver": {
        "entryPoint": "local:///usr/lib/spark/examples/src/main/python/pi.py",
        "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
      }
    }'

else
  echo "Cluster is not in running state $EMR_VIRTUAL_CLUSTER_NAME"
fi
