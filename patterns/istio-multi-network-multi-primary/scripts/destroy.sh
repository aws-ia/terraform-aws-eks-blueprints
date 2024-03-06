#!/bin/sh 

set -e 

source `dirname "$(realpath $0)"`/set-cluster-contexts.sh $1 $2

terraform destroy --auto-approve \
    -target=module.eks_1_addons.helm_release.this \
    -target=module.eks_2_addons.helm_release.this \
    -target=helm_release.multicluster_gateway_n_apps_1 \
    -target=helm_release.multicluster_gateway_n_apps_2

lbServicesExist() {
    o1=`kubectl get svc -n istio-ingress --context $CTX_CLUSTER1 -o json | jq '.items[] | select(.spec.type=="LoadBalancer") // ""' | jq -s length`
    o2=`kubectl get svc -n istio-ingress --context $CTX_CLUSTER2 -o json | jq '.items[] | select(.spec.type=="LoadBalancer") // ""' | jq -s length`
    if [[ $o1 -gt 0 || $o2 -gt 0 ]]; then
        echo "There are $o1 and $o2 LB services in $CTX_CLUSTER1 and $CTX_CLUSTER2 respectively"
        true
    else
        false
    fi
}

while lbServicesExist
do 
    echo "Waiting for 5 (more) seconds for the LB services to clear up ..."
    sleep 5
done

terraform destroy --auto-approve