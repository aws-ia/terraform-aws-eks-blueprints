output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.eks-cluster-with-import-vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.eks-cluster-with-import-vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.eks-cluster-with-import-vpc.public_subnets
}
