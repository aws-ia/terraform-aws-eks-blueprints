
output "managed_nodegroups" {
  description = "EKS Managed node group id"
  value       = aws_eks_node_group.managed_ng[*].id
}

output "managed_nodegroup_iam_role_arn" {
  description = "IAM role ARN for EKS Managed Node Group"
  value       = aws_iam_role.managed_ng[*].arn
}

output "managed_nodegroup_iam_role_name" {
  description = "IAM role Names for EKS Managed Node Group"
  value       = aws_iam_role.managed_ng[*].name
}

output "managed_nodegroup_launch_template_id" {
  description = "launch templated id for EKS Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].id
}

output "managed_nodegroup_launch_template_arn" {
  description = "launch templated id for EKS Self Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].arn
}

output "managed_nodegroup_launch_template_latest_version" {
  description = "launch templated version for EKS Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].default_version
}

output "managed_nodegroup_sec_group_id" {
  description = "Security group ID for Managed node group"
  value       = var.worker_security_group_id == "" ? aws_security_group.managed_ng[*].id : [var.worker_security_group_id]
}
