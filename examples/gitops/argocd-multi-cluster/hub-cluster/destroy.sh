#!/bin/bash

set -x

# Delete the Ingress before removing the addons
kubectl_login=$(terraform output -raw configure_kubectl)
$kubectl_login
kubectl delete ing argo-cd-argocd-server -n argocd
kubectl delete ing grafana -n grafana

terraform destroy -target="module.eks_blueprints_argocd_workloads" -auto-approve
terraform destroy -target="module.eks_blueprints_argocd_addons" -auto-approve
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
