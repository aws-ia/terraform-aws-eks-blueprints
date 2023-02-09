#!/bin/bash

set -xe

terraform destroy -target="module.spoke_cluster.kubernetes_secret_v1.spoke_cluster" -auto-approve
terraform destroy -target="module.spoke_cluster.module.eks_blueprints_argocd_addon" -auto-approve
terraform destroy -target="module.spoke_cluster.module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.spoke_cluster.module.eks_blueprints" -auto-approve
terraform destroy -target="module.spoke_cluster.module.vpc" -auto-approve
terraform destroy -auto-approve