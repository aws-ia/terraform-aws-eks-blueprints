#!/bin/bash

# All the inputs to this script as environment variables 
# REPO_PATH : Local root path of the kubeflow-manifest github repo 
# CLUSTER_NAME : Name of the EKS cluster
# CLUSTER_REGION : Region of the EKS cluster


# Script configuration
set -euo pipefail

function onError {
  echo "Run test FAILED. Exiting."
}
trap onError ERR

export CANARY_TEST_DIR=${REPO_PATH}/tests/canary
export E2E_TEST_DIR=${REPO_PATH}/tests/e2e

# Connect to eks cluster 
aws eks update-kubeconfig --name $CLUSTER_NAME --region $CLUSTER_REGION

# Modify metadeta file
cd $CANARY_TEST_DIR
sed -i 's/$CLUSTER_NAME/'"$CLUSTER_NAME"'/g' metadata-canary
sed -i 's/$CLUSTER_REGION/'"$CLUSTER_REGION"'/g' metadata-canary

mkdir -p $E2E_TEST_DIR/.metadata/
cp metadata-canary $E2E_TEST_DIR/.metadata/

cd $E2E_TEST_DIR
pytest tests/test_sanity_portforward.py -s -q --metadata .metadata/metadata-canary --keepsuccess --region $CLUSTER_REGION


