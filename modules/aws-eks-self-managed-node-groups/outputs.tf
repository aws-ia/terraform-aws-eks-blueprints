output "self_managed_nodegroup_name" {
  description = "EKS Self Managed node group id"
  value       = local.self_managed_node_group["node_group_name"][*]
}

output "self_managed_nodegroup_iam_role_arns" {
  description = "Self managed groups IAM role arns"
  value       = aws_iam_role.self_managed_ng[*].arn
}

output "self_managed_iam_role_name" {
  description = "Self managed groups IAM role names"
  value       = aws_iam_role.self_managed_ng[*].name
}

output "self_managed_asg_names" {
  description = "Self managed group ASG names"
  value       = aws_autoscaling_group.self_managed_ng[*].name
}

output "launch_template_latest_versions" {
  description = "Launch Template latest versions for EKS Self Managed Node Group"
  value       = module.launch_template_self_managed_ng.launch_template_latest_version
}

output "launch_template_ids" {
  description = "Launch Template IDs for EKS Self Managed Node Group"
  value       = module.launch_template_self_managed_ng.launch_template_id
}

output "launch_template_arn" {
  description = "Launch Template ARNs for EKS Self Managed Node Group"
  value       = module.launch_template_self_managed_ng.launch_template_arn
}

output "self_managed_nodegroup_iam_instance_profile_id" {
  description = "IAM Instance Profile ID for EKS Self Managed Node Group"
  value       = aws_iam_instance_profile.self_managed_ng[*].id
}

output "self_managed_nodegroup_iam_instance_profile_arn" {
  description = "IAM Instance Profile and for EKS Self Managed Node Group"
  value       = aws_iam_instance_profile.self_managed_ng[*].arn
}
