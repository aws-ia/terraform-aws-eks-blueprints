#!/bin/bash
set -euo pipefail

curl -o max-pods-calculator.sh https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/files/max-pods-calculator.sh
chmod +x max-pods-calculator.sh

# TODO: retrieve the cni-version from installed add-on
# aws eks describe-addon --cluster-name $cluster_name --addon-name vpc-cni --query "addon.addonVersion" --output text

# Temporary use CNI version '1.11.2-eksbuild.1'.
# Ref: https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
max_pod_number=$(./max-pods-calculator.sh --instance-type $1 --cni-version 1.11.2-eksbuild.1)
echo -n "{\"max_pod_number\":\"${max_pod_number}\"}"