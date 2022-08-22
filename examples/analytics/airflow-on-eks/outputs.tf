output "vpc_private_subnet_cidr" {
  description = "VPC private subnet CIDR"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "vpc_public_subnet_cidr" {
  description = "VPC public subnet CIDR"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_blueprints.eks_cluster_id
}

output "eks_managed_nodegroups" {
  description = "EKS managed node groups"
  value       = module.eks_blueprints.managed_node_groups
}

output "eks_managed_nodegroup_ids" {
  description = "EKS managed node group ids"
  value       = module.eks_blueprints.managed_node_groups_id
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "airflow_db" {
  value     = data.aws_secretsmanager_secret_version.postgres.secret_string
  sensitive = true
}
