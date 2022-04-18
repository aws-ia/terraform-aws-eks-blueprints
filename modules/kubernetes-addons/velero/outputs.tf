# If you are allowing GitOps based management for your addon,
# this output must be provided.
output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? local.argocd_gitops_config : null
}
