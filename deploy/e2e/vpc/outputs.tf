output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.eks_cluster_with_import_vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.eks_cluster_with_import_vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.eks_cluster_with_import_vpc.public_subnets
}
