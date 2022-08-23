output "irsa_iam_role_arn" {
  description = "IAM role ARN for your service account"
  value       = try(aws_iam_role.irsa[0].arn, null)
}

output "irsa_iam_role_name" {
  description = "IAM role name for your service account"
  value       = try(aws_iam_role.irsa[0].name, null)
}

output "namespace" {
  description = "IRSA Namespace"
  value       = try(kubernetes_namespace_v1.irsa[0].id, var.kubernetes_namespace)
}

output "service_account" {
  description = "IRSA Service Account"
  value       = try(kubernetes_service_account_v1.irsa[0].id, var.kubernetes_service_account)
}
