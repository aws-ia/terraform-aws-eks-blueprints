output "self_managed_node_group_name" {
  description = "EKS Self Managed node group id"
  value       = local.self_managed_node_group["node_group_name"].*
}

output "self_managed_node_group_iam_role_arns" {
  value = aws_iam_role.self_managed_ng[*].arn
}

output "self_managed_iam_role_name" {
  value = aws_iam_role.self_managed_ng[*].name
}

output "self_managed_sec_group_id" {
  value = var.default_worker_security_group_id == "" ? aws_security_group.self_managed_ng[*].id : [var.default_worker_security_group_id]
}

output "self_managed_asg_name" {
  value = aws_autoscaling_group.self_managed_ng[*].name
}

output "launch_template_latest_versions" {
  description = "launch templated version for EKS Self Managed Node Group"
  value       = aws_launch_template.self_managed_ng[*].latest_version
}

output "launch_template_ids" {
  description = "launch templated id for EKS Self Managed Node Group"
  value       = aws_launch_template.self_managed_ng[*].id
}

output "launch_template_arn" {
  description = "launch templated id for EKS Self Managed Node Group"
  value       = aws_launch_template.self_managed_ng[*].arn
}
