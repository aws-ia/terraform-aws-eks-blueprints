output "vpc_private_subnet_cidr" {
  value = module.aws_vpc.private_subnets_cidr_blocks
}

output "vpc_public_subnet_cidr" {
  value = module.aws_vpc.public_subnets_cidr_blocks
}

output "vpc_cidr" {
  value = module.aws_vpc.vpc_cidr_block
}

output "eks_cluster_id" {
  value = module.eks_blueprints.eks_cluster_id
}

# Managed Node group name
output "eks_managed_nodegroups" {
  value = module.eks_blueprints.managed_node_groups
}

# Managed Node group id
output "eks_managed_nodegroup_ids" {
  value = module.eks_blueprints.managed_node_groups_id
}

# Managed Node group id
output "eks_managed_nodegroup_arns" {
  value = module.eks_blueprints.managed_node_group_arn
}

# Managed Node group role name
output "eks_managed_nodegroup_role_name" {
  value = module.eks_blueprints.managed_node_group_iam_role_names
}

# Managed Node group status
output "eks_managed_nodegroup_status" {
  value = module.eks_blueprints.managed_node_groups_status
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

# Region used for Terratest
output "region" {
  value       = var.region
  description = "AWS region"
}
