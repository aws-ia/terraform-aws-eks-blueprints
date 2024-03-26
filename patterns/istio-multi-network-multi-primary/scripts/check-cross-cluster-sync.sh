#!/bin/sh

set -e

source `dirname "$(realpath $0)"`/set-cluster-contexts.sh $1 $2

cross_cluster_sync() {
    ctx=$1
    POD_NAME=$(kubectl get pod --context=$ctx -l app=sleep -o jsonpath='{.items[0].metadata.name}' -n sample)
    istioctl --context $ctx proxy-config endpoint $POD_NAME -n sample | grep helloworld
}

for ctx in $CTX_CLUSTER1 $CTX_CLUSTER2
do 
    echo "\nCross cluster sync check for $ctx:"
    cross_cluster_sync $ctx
done