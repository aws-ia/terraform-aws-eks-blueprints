output "helm_release" {
  description = "Map of attributes of the Helm release created without sensitive outputs"
  value       = try(module.helm_addon[0].helm_release, {})
}

output "irsa_arn" {
  description = "IAM role ARN for the service account"
  value       = try(module.helm_addon[0].irsa_arn, null)
}

output "irsa_name" {
  description = "IAM role name for the service account"
  value       = try(module.helm_addon[0].irsa_name, null)
}

output "service_account" {
  description = "Name of Kubernetes service account"
  value       = try(module.helm_addon[0].service_account, null)
}
