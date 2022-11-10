output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? local.argocd_gitops_config : null
}

output "eks_cluster_id" {
  description = "Current AWS EKS Cluster ID"
  value       = var.addon_context.eks_cluster_id
}
