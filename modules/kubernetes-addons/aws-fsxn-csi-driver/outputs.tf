output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? local.argocd_gitops_config : null
}

output "release_metadata" {
  description = "Map of attributes of the Helm release metadata"
  value       = module.helm_addon.release_metadata
}

