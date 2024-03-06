#!/bin/sh 

set -e

source `dirname "$(realpath $0)"`/set-cluster-contexts.sh $1 $2

readiness() {
    CTX=$1 

    EW_LB_NAME=$(kubectl get svc istio-eastwestgateway -n istio-ingress --context $CTX -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}')

    EW_LB_ARN=$(aws elbv2 describe-load-balancers | \
    jq -r --arg EW_LB_NAME "$EW_LB_NAME" \
    '.LoadBalancers[] | select(.DNSName == $EW_LB_NAME) | .LoadBalancerArn')

    TG_ARN=$(aws elbv2 describe-listeners --load-balancer-arn $EW_LB_ARN | jq -r '.Listeners[] | select(.Port == 15443) | .DefaultActions[0].TargetGroupArn')

    aws elbv2 describe-target-health --target-group-arn $TG_ARN | jq -r '.TargetHealthDescriptions[0]'
}

for ctx in $CTX_CLUSTER1 $CTX_CLUSTER2
do 
    echo "\nReadiness check for $ctx:"
    readiness $ctx
done