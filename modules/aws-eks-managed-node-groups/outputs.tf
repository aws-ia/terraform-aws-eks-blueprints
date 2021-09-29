
output "node_groups" {
  description = "EKS Managed node group id"
  value       = aws_eks_node_group.managed_ng[*].id
}

output "manage_ng_iam_role_arn" {
  description = "IAM role ARN for EKS Managed Node Group"
  value       = aws_iam_role.managed_ng[*].arn
}

output "manage_ng_iam_role_name" {
  description = "IAM role Names for EKS Managed Node Group"
  value       = aws_iam_role.managed_ng[*].name
}

output "launch_template_ids" {
  description = "launch templated id for EKS Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].id
}

output "launch_template_arn" {
  description = "launch templated id for EKS Self Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].arn
}

output "launch_template_latest_versions" {
  description = "launch templated version for EKS Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].default_version
}