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

output "cluster1_additional_sg_id" {
  description = "Cluster1 additional SG"
  value       = aws_security_group.cluster1_additional_sg.id
}

output "cluster2_additional_sg_id" {
  description = "Cluster2 additional SG"
  value       = aws_security_group.cluster2_additional_sg.id
}
