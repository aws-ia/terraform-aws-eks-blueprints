output "managed_nodegroup_id" {
  description = "EKS Managed node group id"
  value       = aws_eks_node_group.managed_ng[*].id
}

output "managed_nodegroup_arn" {
  description = "EKS Managed node group id"
  value       = aws_eks_node_group.managed_ng[*].arn
}

output "managed_nodegroup_status" {
  description = "EKS Managed Node Group status"
  value       = aws_eks_node_group.managed_ng[*].status
}

output "managed_nodegroup_iam_role_arn" {
  description = "IAM role ARN for EKS Managed Node Group"
  value       = aws_iam_role.managed_ng[*].arn
}

output "managed_nodegroup_iam_role_name" {
  description = "IAM role name for EKS Managed Node Group"
  value       = aws_iam_role.managed_ng[*].name
}

output "managed_nodegroup_iam_instance_profile_id" {
  description = "IAM instance profile id for EKS Managed Node Group"
  value       = aws_iam_instance_profile.managed_ng[*].id
}

output "managed_nodegroup_iam_instance_profile_arn" {
  description = "IAM instance profile arn for EKS Managed Node Group"
  value       = aws_iam_instance_profile.managed_ng[*].arn
}

output "managed_nodegroup_launch_template_id" {
  description = "Launch Template ID for EKS Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].id
}

output "managed_nodegroup_launch_template_arn" {
  description = "Launch Template ARN for EKS Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].arn
}

output "managed_nodegroup_launch_template_latest_version" {
  description = "Launch Template version for EKS Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].default_version
}
