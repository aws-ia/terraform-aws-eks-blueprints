#!/bin/bash

set -xe

terraform destroy -target="module.kubernetes_secret_v1.spoke_cluster" -auto-approve
terraform destroy -target="module.module.eks_blueprints_argocd_addon" -auto-approve
terraform destroy -target="module.module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.module.eks_blueprints" -auto-approve
terraform destroy -target="module.module.vpc" -auto-approve
terraform destroy -auto-approve