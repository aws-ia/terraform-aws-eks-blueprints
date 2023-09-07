#!/bin/bash
set -e

# Get the directory of the currently executing script (shell1.sh)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

{ "$SCRIPT_DIR/tear-down-applications.sh"; } || {
  echo "Error occurred while deleting application"

  # Ask the user if they want to continue
  read -p "Do you want to continue with cluster deletion (y/n)? " choice
  case "$choice" in
    y|Y ) echo "Continuing with the rest of shell1.sh";;
    * ) echo "Exiting.."; exit;;
  esac
}

kubectl delete svc -n argocd argo-cd-argocd-server

# terraform destroy -target="module.gitops_bridge_bootstrap" -auto-approve
# terraform destroy -target="module.eks_blueprints_addons" -auto-approve
# terraform destroy -target="module.eks" -auto-approve
# terraform destroy -target="module.vpc" -auto-approve
# terraform destroy -auto-approve


# Then Tear down the cluster
terraform apply -destroy -target="module.eks_cluster.module.kubernetes_addons" -auto-approve || (echo "error deleting module.eks_cluster.module.kubernetes_addons" && exit -1)
terraform apply -destroy -target="module.eks_cluster.module.eks" -auto-approve || (echo "error deleting module.eks_cluster.module.eks" && exit -1)
terraform apply -destroy -auto-approve || (echo "error deleting terraform" && exit -1)

echo "Tear Down OK"
