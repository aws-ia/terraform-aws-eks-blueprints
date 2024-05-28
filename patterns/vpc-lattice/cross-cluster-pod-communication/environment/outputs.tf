
output "region" {
  description = "The AWS Region"
  value       = local.region
}

output "private_zone_id" {
  description = "The ID of the private hosted zone"
  value       = aws_route53_zone.private_zone.id
}

output "custom_domain_name" {
  description = "Custom domain name for the private hosted zone"
  value       = var.custom_domain_name
}

output "aws_acm_cert_arn" {
  description = "Arn of private Certificate"
  value       = aws_acm_certificate.private_domain_cert.arn
}

output "route53_private_zone_arn" {
  description = "Arn of Amazon Route53 Private Zone"
  value       = aws_route53_zone.private_zone.arn
}

output "vpc_lattice_client_role_arn" {
  value       = aws_iam_role.vpc_lattice_role.arn
  description = "ARN of the IAM role for VPC Lattice access"
}
