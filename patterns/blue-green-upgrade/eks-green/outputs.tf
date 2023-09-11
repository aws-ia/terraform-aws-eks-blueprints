output "eks_cluster_id" {
  description = "The name of the EKS cluster."
  value       = module.eks_cluster.eks_cluster_id
}

output "eks_blueprints_platform_teams_configure_kubectl" {
  description = "Configure kubectl Platform Team: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_cluster.eks_blueprints_platform_teams_configure_kubectl
}

output "eks_blueprints_dev_teams_configure_kubectl" {
  description = "Configure kubectl for each Dev Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_cluster.eks_blueprints_dev_teams_configure_kubectl
}

output "eks_blueprints_ecsdemo_teams_configure_kubectl" {
  description = "Configure kubectl for each ECSDEMO Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_cluster.eks_blueprints_ecsdemo_teams_configure_kubectl
}
