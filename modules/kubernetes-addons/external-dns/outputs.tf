output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with GitOps"
  value       = var.manage_via_gitops ? local.argocd_gitops_config : null
}
