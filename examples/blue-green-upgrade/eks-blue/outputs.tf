output "eks_cluster_id" {
  description = "The name of the EKS cluster."
  value       = module.eks_cluster.eks_cluster_id
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_cluster.configure_kubectl
}
