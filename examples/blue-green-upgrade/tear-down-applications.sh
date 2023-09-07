#!/bin/bash
set -e

# First tear down Applications
kubectl delete provisioners.karpenter.sh --all # this is ok if no addons are deployed on Karpenter.
kubectl delete application bootstrap-workloads -n argocd || (echo "error deleting bootstrap-workloads application" && exit -1)
kubectl delete application -l argocd.argoproj.io/application-set-name=eks-blueprints-workloads -n argocd || (echo "error deleting workloads application"; exit -1)

#kubectl delete application ecsdemo -n argocd || (echo "error deleting ecsdemo application" && exit -1)

#namespace geordie was stuck
#kubectl get applications  -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | xargs -I {} kubectl patch application {}  --type=json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'

for x in $(kubectl get namespaces -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}') ; do
  echo $x
  kubectl get -n $x ingress  -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | xargs -I {} kubectl patch -n $x ingress {}  --type=json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
done

#Error from server (InternalError): Internal error occurred: failed calling webhook "vingress.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/validate-networking-v1-ingress?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"

echo "Tear Down Applications OK"
