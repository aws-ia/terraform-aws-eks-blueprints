output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "eks_blueprints_kubernetes_addons" {
  description = "Map of attributes of the EKS Blueprints Kubernetes addons Helm release and IRSA created"
  value       = module.eks_blueprints_kubernetes_addons
}

output "kyverno_addon" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.eks_blueprints_kubernetes_addons.kyverno
}

output "kyverno_values" {
  description = "Values used in the Kyverno Helm release"
  value       = jsondecode(module.eks_blueprints_kubernetes_addons.kyverno.release_metadata[0].values)
}
