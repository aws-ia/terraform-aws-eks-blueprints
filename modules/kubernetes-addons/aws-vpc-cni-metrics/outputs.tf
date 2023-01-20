output "irsa_arn" {
  description = "IAM role ARN for the service account"
  value       = try(module.vpc_cni_metrics_addon[0].iam_role_arn, null)
}

output "irsa_name" {
  description = "IAM role name for the service account"
  value       = try(module.vpc_cni_metrics_addon[0].iam_role_name, null)
}
