# EKS Cluster with Existing VPC State

This example scenario used to create an EKS Cluster with one Managed Node group by importing VPC ID, three Private Subnet IDs,
three Public Subnet IDs from the remote state file.

 - Import existing VPC, 3 Private Subnets and 3 Public Subnets using remote state file
 - Creates an EKS Cluster Control plane with public endpoint with one managed node group
