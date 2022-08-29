output "helm_release" {
  description = "Map of attributes of the Helm release created without sensitive outputs"
  value       = try({ for k, v in helm_release.addon : k => v if k != "repository_password" }, {})
}

output "irsa" {
  description = "Irsa configuration of the helm addon"
  value = var.irsa_config != null ? {
    role_name       = module.irsa[0].irsa_iam_role_name
    role_arn        = module.irsa[0].irsa_iam_role_arn
    service_account = module.irsa[0].service_account
  } : {}
}
