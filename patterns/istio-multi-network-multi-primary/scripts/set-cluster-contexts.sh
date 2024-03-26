#!/bin/sh 

CLUSTER_1_NAME=${1:-eks-1}
CLUSTER_2_NAME=${2:-eks-2}

aws eks update-kubeconfig --region us-west-2 --name $CLUSTER_1_NAME
aws eks update-kubeconfig --region us-west-2 --name $CLUSTER_2_NAME

export CTX_CLUSTER1=`aws eks describe-cluster --name $CLUSTER_1_NAME | jq -r '.cluster.arn'`
export CTX_CLUSTER2=`aws eks describe-cluster --name $CLUSTER_2_NAME | jq -r '.cluster.arn'`