output "ingress_namespace" {
  value       = local.helm_config["namespace"]
  description = "AWS LoadBalancer Controller Ingress Namespace"
}

output "ingress_name" {
  value       = local.helm_config["name"]
  description = "AWS LoadBalancer Controller Ingress Name"
}

output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? local.argocd_gitops_config : null
}
