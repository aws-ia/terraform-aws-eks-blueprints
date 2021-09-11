output "self_managed_node_group_iam_arns" {
  value = aws_iam_role.self_managed_ng[*].arn
}

output "self_managed_iam_role_name" {
  value = aws_iam_role.self_managed_ng[*].name
}

output "self_managed_sec_group_name" {
  value = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
}

output "self_managed_asg_name" {
  value = aws_autoscaling_group.self_managed_ng[*].name
}