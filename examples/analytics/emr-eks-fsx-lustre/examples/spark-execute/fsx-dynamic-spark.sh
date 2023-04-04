#!/bin/bash

if [ $# -ne 3 ];
then
  echo "$0: Missing arguments ENTER_EMR_VIRTUAL_CLUSTER_ID,  S3_BUCKET and EMR_JOB_EXECUTION_ROLE_ARN"
  echo "USAGE: ./fsx-dynamic-spark.sh '<ENTER_EMR_VIRTUAL_CLUSTER_ID>' '<s3://ENTER_BUCKET_NAME>' '<EMR_JOB_EXECUTION_ROLE_ARN>'"
  exit 1
else
  echo "We got some argument(s)"
  echo "==========================="
  echo "Number of arguments.: $#"
  echo "List of arguments...: $@"
  echo "Arg #1..............: $1"
  echo "Arg #2..............: $2"
  echo "Arg #3..............: $3"
  echo "==========================="
fi

#--------------------------------------------
# INPUT VARIABLES
#--------------------------------------------
EMR_VIRTUAL_CLUSTER_ID=$1     # Terraform output variable is `emrcontainers_virtual_cluster_id`
S3_BUCKET=$2                  # This script requires s3 bucket as input parameter e.g., s3://<bucket-name>
EMR_JOB_EXECUTION_ROLE_ARN=$3 # Terraform output variable is emr_on_eks_role_arn

#--------------------------------------------
# DERIVED VARIABLES
#--------------------------------------------
EMR_VIRTUAL_CLUSTER_NAMESPACE=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?id=='${EMR_VIRTUAL_CLUSTER_ID}' && state=='RUNNING'].containerProvider.info.eksInfo" --output text)
EMR_VIRTUAL_CLUSTER_NAME=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?id=='${EMR_VIRTUAL_CLUSTER_ID}' && state=='RUNNING'].name" --output text)

#--------------------------------------------
# DEFAULT VARIABLES CAN BE MODIFIED
#--------------------------------------------
JOB_NAME='ny-taxi-trip-dynamic'
EMR_EKS_RELEASE_LABEL="emr-6.5.0-latest"
SPARK_JOB_S3_PATH="${S3_BUCKET}/emr_virtual_cluster_name=${EMR_VIRTUAL_CLUSTER_NAME}/namespace=${EMR_VIRTUAL_CLUSTER_NAMESPACE}/job_name=${JOB_NAME}"

#--------------------------------------------
# CLOUDWATCH LOG GROUP NAME
#--------------------------------------------
CW_LOG_GROUP="/emr-on-eks-logs/${EMR_VIRTUAL_CLUSTER_NAME}/${EMR_VIRTUAL_CLUSTER_NAMESPACE}" # Create CW Log group if not exist

#--------------------------------------------
# Download sample input data from https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page
#--------------------------------------------
# Create folder locally to store the input data
mkdir -p "spark-scripts/input"

# Download the input data from public data set to local folders
max=40
for (( i=1; i <= $max; ++i ))
do
    wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2022-01.parquet -O "spark-scripts/input/yellow_tripdata_2022-${i}.parquet"
done

#--------------------------------------------
# This command copies PySpark script and the Pod templates to S3 bucket
#--------------------------------------------
aws s3 sync ./spark-scripts/ "${SPARK_JOB_S3_PATH}/"

#--------------------------------------------
# Execute Spark job
#--------------------------------------------

if [[ $EMR_VIRTUAL_CLUSTER_ID != "" ]]; then
  echo "Found Cluster $EMR_VIRTUAL_CLUSTER_NAME; Executing the Spark job now..."
  aws emr-containers start-job-run \
    --virtual-cluster-id $EMR_VIRTUAL_CLUSTER_ID \
    --name $JOB_NAME \
    --execution-role-arn $EMR_JOB_EXECUTION_ROLE_ARN \
    --release-label $EMR_EKS_RELEASE_LABEL \
    --job-driver '{
      "sparkSubmitJobDriver": {
        "entryPoint": "'"$SPARK_JOB_S3_PATH"'/scripts/sample-spark-taxi-trip.py",
        "entryPointArguments": ["'"$SPARK_JOB_S3_PATH"'/input/",
          "'"$SPARK_JOB_S3_PATH"'/output/"
        ],
        "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.cores=1 --conf spark.driver.cores=1"
      }
   }' \
    --configuration-overrides '{
      "applicationConfiguration": [
          {
            "classification": "spark-defaults",
            "properties": {
              "spark.kubernetes.driver.podTemplateFile":"'"$SPARK_JOB_S3_PATH"'/pod-templates/fsx-dynamic-spark-driver.yaml",
              "spark.kubernetes.executor.podTemplateFile":"'"$SPARK_JOB_S3_PATH"'/pod-templates/fsx-dynamic-spark-executor.yaml",
              "spark.driver.memory":"2g",
              "spark.executor.memory":"4g",
              "spark.kubernetes.executor.podNamePrefix":"'"$JOB_NAME"'",
              "spark.ui.prometheus.enabled":"true",
              "spark.executor.processTreeMetrics.enabled":"true",
              "spark.kubernetes.driver.annotation.prometheus.io/scrape":"true",
              "spark.kubernetes.driver.annotation.prometheus.io/path":"/metrics/executors/prometheus/",
              "spark.kubernetes.driver.annotation.prometheus.io/port":"4040",
              "spark.kubernetes.driver.service.annotation.prometheus.io/scrape":"true",
              "spark.kubernetes.driver.service.annotation.prometheus.io/path":"/metrics/driver/prometheus/",
              "spark.kubernetes.driver.service.annotation.prometheus.io/port":"4040",
              "spark.metrics.conf.*.sink.prometheusServlet.class":"org.apache.spark.metrics.sink.PrometheusServlet",
              "spark.metrics.conf.*.sink.prometheusServlet.path":"/metrics/driver/prometheus/",
              "spark.metrics.conf.master.sink.prometheusServlet.path":"/metrics/master/prometheus/",
              "spark.metrics.conf.applications.sink.prometheusServlet.path":"/metrics/applications/prometheus/"
            }
          }
        ],
      "monitoringConfiguration": {
        "persistentAppUI":"ENABLED",
        "cloudWatchMonitoringConfiguration": {
          "logGroupName":"'"$CW_LOG_GROUP"'",
          "logStreamNamePrefix":"'"$JOB_NAME"'"
        }
      }
    }'
else
  echo "Cluster is not in running state $EMR_VIRTUAL_CLUSTER_NAME"
fi

#--------------------------------------------
# Delete locally downloaded test data
#--------------------------------------------
rm -rf spark-scripts/input
