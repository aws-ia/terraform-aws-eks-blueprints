#!/bin/bash

set -xe

terraform destroy -target="module.eks_blueprints_argocd_workloads" -auto-approve
sleep 60 # wait for argocd apps to be deleted
terraform destroy -target="module.eks_blueprints_argocd_addons" -auto-approve
sleep 60 # wait for argocd apps to be deleted
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
