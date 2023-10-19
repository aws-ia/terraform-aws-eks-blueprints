output "vpc_id" {
  description = "Amazon EKS VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "Amazon EKS Subnet IDs"
  value       = module.vpc.private_subnets
}

output "vpc_cidr" {
  description = "Amazon EKS VPC CIDR Block."
  value       = local.vpc_cidr
}
