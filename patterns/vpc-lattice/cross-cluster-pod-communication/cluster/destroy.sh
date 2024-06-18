#!/bin/bash

set -uo pipefail

[[ -n "${DEBUG:-}" ]] && set -x

# Check if a parameter is provided
if [ -z "$1" ]; then
    echo "Error: No workspace provided."
    echo "Usage: $0 <parameter>"
    exit 1
fi

WORKSPACE=$1


cleanup_vpc_resources() {
    local WORKSPACE=$1

    VPCID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=eks-$WORKSPACE" --query "Vpcs[*].VpcId" --output text)
    echo $VPCID
    for endpoint in $(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPCID" --query "VpcEndpoints[*].VpcEndpointId" --output text); do
        aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $endpoint
    done

    #Dissassociate from VPC lattice
    assoc=$(aws vpc-lattice list-service-network-vpc-associations --vpc-identifier $VPCID | jq ".items[0].arn" -r)
    echo $assoc
    aws vpc-lattice delete-service-network-vpc-association --service-network-vpc-association-identifier $assoc
    sleep 20

    # Get the list of security group IDs associated with the VPC
    security_group_ids=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPCID" --query "SecurityGroups[*].GroupId" --output json)

    # Check if any security groups were found
    if [ -z "$security_group_ids" ]; then
        echo "No security groups found in VPC $VPCID"
    else
        echo "security_group_ids=$security_group_ids"

        # Loop through the security group IDs and delete each security group
        for group_id in $(echo "$security_group_ids" | jq -r '.[]'); do
            echo "Deleting security group $group_id"
            aws ec2 delete-security-group --group-id "$group_id"
        done
    fi
}

terraform workspace select $WORKSPACE
terraform destroy -target="helm_release.demo_application" -auto-approve
terraform destroy -target="helm_release.platform_application" -auto-approve

#Remove addons
terraform destroy -target="module.eks_blueprints_addon_kyverno" -auto-approve
terraform destroy -target="module.eks_blueprints_addons" -auto-approve

#Remove EKS cluster
terraform destroy -target="module.eks" -auto-approve

cleanup_vpc_resources $WORKSPACE

# # clean everything else
terraform destroy -auto-approve || true

#Do it 2 tims to be sure to delete everything
cleanup_vpc_resources $WORKSPACE

terraform destroy -auto-approve

if [ $? -eq 0 ]; then
    echo "Success: VPC $VPCID deleted successfully."
else
    echo "Error: Failed to delete VPC $VPCID, you may need to do some manuals cleanups"
fi

