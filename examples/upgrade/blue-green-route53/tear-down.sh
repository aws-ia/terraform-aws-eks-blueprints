#!/bin/bash
set -e

# First tear down Applications
kubectl delete application workloads -n argocd || (echo "error deleting workloads application"; exit -1)
kubectl delete application ecsdemo -n argocd || (echo "error deleting ecsdemo application" && exit -1)

# Then Tear down the cluster
terraform apply -destroy -target="module.kubernetes_addons" -auto-approve || (echo "error deleting module.kubernetes_addons" && exit -1)
terraform apply -destroy -target="module.eks_blueprints" -auto-approve || (echo "error deleting eks-blueprint" && exit -1)
terraform apply -destroy -auto-approve || (echo "error deleting terraform" && exit -1)

echo "Tear Down OK"
