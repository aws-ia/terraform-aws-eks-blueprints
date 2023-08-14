output "vpc_id" {
  value = module.vpc.vpc_id
}
output "subnet_ids" {
  value = module.vpc.private_subnets
}
output "vpc_cidr" {
  value = local.vpc_cidr
}

output "cluster1_additional_sg_id" {
  description = "cluster1_additional_sg"
  value       = aws_security_group.cluster1_additional_sg.id
}

output "cluster2_additional_sg_id" {
  description = "cluster2_additional_sg"
  value       = aws_security_group.cluster2_additional_sg.id
}
