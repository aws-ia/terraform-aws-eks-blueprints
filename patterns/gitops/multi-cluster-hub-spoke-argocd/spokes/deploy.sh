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
echo "Deploying $env with "workspaces/${env}.tfvars" ..."


if terraform workspace list | grep -q $env; then
    echo "Workspace $env already exists."
else
    terraform workspace new $env
fi

terraform workspace select $env
terraform init
terraform apply -var-file="workspaces/${env}.tfvars"
