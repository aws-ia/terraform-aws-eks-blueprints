output "release_metadata" {
  description = "Map of attributes of the Helm release metadata"
  value       = module.kyverno_helm_addon.release_metadata
}

output "irsa_arn" {
  description = "IAM role ARN for the service account"
  value       = module.kyverno_helm_addon.irsa_arn
}

output "irsa_name" {
  description = "IAM role name for the service account"
  value       = module.kyverno_helm_addon.irsa_name
}

output "service_account" {
  description = "Name of Kubernetes service account"
  value       = module.kyverno_helm_addon.service_account
}
