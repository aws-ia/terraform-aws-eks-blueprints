output "helm_release" {
  description = "Map of attributes of the Helm release created without sensitive outputs"
  value       = try({ for k, v in helm_release.addon : k => v if k != "repository_password" }, {})
}

output "release_metadata" {
  description = "Map of attributes of the Helm release metadata"
  value       = try(helm_release.addon[0].metadata, null)
}

output "irsa_arn" {
  description = "IAM role ARN for the service account"
  value       = try(module.irsa[0].irsa_iam_role_arn, null)
}

output "irsa_name" {
  description = "IAM role name for the service account"
  value       = try(module.irsa[0].irsa_iam_role_name, null)
}

output "service_account" {
  description = "Name of Kubernetes service account"
  value       = try(coalesce(try(module.irsa[0].service_account, null), lookup(var.irsa_config, "kubernetes_service_account", null)), null)
}
