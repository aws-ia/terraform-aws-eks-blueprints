output "release_metadata" {
  description = "Map of attributes of the Helm release metadata"
  value       = module.helm_addon.release_metadata
}

output "service_account" {
  description = "Name of Kubernetes service account"
  value       = module.helm_addon.service_account
}
