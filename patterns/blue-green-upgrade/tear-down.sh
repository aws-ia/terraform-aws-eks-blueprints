#!/bin/bash
set -e

# First tear down Applications
kubectl delete provisioners.karpenter.sh --all # this is ok if no addons are deployed on Karpenter.
kubectl delete application workloads -n argocd || (echo "error deleting workloads application"; exit -1)
kubectl delete application ecsdemo -n argocd || (echo "error deleting ecsdemo application" && exit -1)

# Then Tear down the cluster
terraform apply -destroy -target="module.eks_cluster.module.kubernetes_addons" -auto-approve || (echo "error deleting module.eks_cluster.module.kubernetes_addons" && exit -1)
terraform apply -destroy -target="module.eks_cluster.module.eks" -auto-approve || (echo "error deleting module.eks_cluster.module.eks" && exit -1)
terraform apply -destroy -auto-approve || (echo "error deleting terraform" && exit -1)

echo "Tear Down OK"
