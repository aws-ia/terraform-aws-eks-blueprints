#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo "No arguments supplied"
    echo "Usage: deploy.sh <environment>"
    echo "Example: deploy.sh dev"
    exit 1
fi
env=$1
echo "Deploying $env with "workspaces/${env}.tfvars" ..."

set -x

terraform workspace new $env
terraform workspace select $env
terraform init
terraform apply -var-file="workspaces/${env}.tfvars"
