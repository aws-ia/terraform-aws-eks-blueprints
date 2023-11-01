#!/bin/bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x


if [[ $# -eq 0 ]] ; then
    echo "No arguments supplied"
    echo "Usage: destroy.sh <environment>"
    echo "Example: destroy.sh dev"
    exit 1
fi
env=$1
echo "Destroying $env ..."
terraform workspace select $env

terraform destroy -auto-approve -var-file="workspaces/${env}.tfvars" -target="module.gitops_bridge_bootstrap" -auto-approve
terraform destroy -auto-approve -var-file="workspaces/${env}.tfvars" -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -auto-approve -var-file="workspaces/${env}.tfvars" -target="module.eks" -auto-approve
terraform destroy -auto-approve -var-file="workspaces/${env}.tfvars" -target="module.vpc" -auto-approve
terraform destroy -auto-approve -var-file="workspaces/${env}.tfvars"
