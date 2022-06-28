output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.aws_vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.aws_vpc.private_subnets
}

output "cloud9_url" {
  description = "Url to the Cloud9 Instance"
  value       = "https://${var.region}.console.aws.amazon.com/cloud9/ide/${aws_cloud9_environment_ec2.eks_cloud9.id}"
}
