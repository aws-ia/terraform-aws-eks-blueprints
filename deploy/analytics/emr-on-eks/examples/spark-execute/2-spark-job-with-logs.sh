#!/bin/bash

# INPUT VARIABLES
EMR_ON_EKS_ROLE_ID="aws001-preprod-test-emr-eks-data-team-a"       # Replace EMR IAM role with your ID
EKS_CLUSTER_ID='aws001-preprod-test-eks'        # Replace cluster id with your id
EMR_ON_EKS_NAMESPACE='emr-data-team-a'                             # Replace namespace with your namespace
EMR_VIRTUAL_CLUSTER_NAME="$EKS_CLUSTER_ID-$EMR_ON_EKS_NAMESPACE"
JOB_NAME='pi'

S3_BUCKET='s3://<enter-your-bucket-name>'                   # Create your own s3 bucket and replace this value
CW_LOG_GROUP="/emr-on-eks-logs/${EMR_VIRTUAL_CLUSTER_NAME}/${EMR_ON_EKS_NAMESPACE}" # Create CW Log group if not exist
SPARK_JOB_S3_PATH="${S3_BUCKET}/${EMR_VIRTUAL_CLUSTER_NAME}/${EMR_ON_EKS_NAMESPACE}/${JOB_NAME}"


# FIND ROLE ARN and EMR VIRTUAL CLUSTER ID
EMR_ROLE_ARN=$(aws iam get-role --role-name $EMR_ON_EKS_ROLE_ID --query Role.Arn --output text)
VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?name=='${EMR_VIRTUAL_CLUSTER_NAME}' && state=='RUNNING'].id" --output text)

# Execute Spark job
if [[ $VIRTUAL_CLUSTER_ID != "" ]]; then
  echo "Found Cluster $EMR_VIRTUAL_CLUSTER_NAME; Executing the Spark job now..."
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
   }' \
    --configuration-overrides '{
      "monitoringConfiguration": {
        "persistentAppUI":"ENABLED",
        "cloudWatchMonitoringConfiguration": {
          "logGroupName":"'"$CW_LOG_GROUP"'",
          "logStreamNamePrefix":"'"$JOB_NAME"'"
        },
        "s3MonitoringConfiguration": {
          "logUri":"'"$SPARK_JOB_S3_PATH"'/logs/"
        }
      }
    }'


else
  echo "Cluster is not in running state $EMR_VIRTUAL_CLUSTER_NAME"
fi
