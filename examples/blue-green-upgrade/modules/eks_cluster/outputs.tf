output "eks_cluster_id" {
  description = "The name of the EKS cluster."
  value       = module.eks_blueprints.eks_cluster_id
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = module.eks_blueprints.eks_cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "eks_cluster_certificate_authority_data"
  value       = module.eks_blueprints.eks_cluster_certificate_authority_data
}
