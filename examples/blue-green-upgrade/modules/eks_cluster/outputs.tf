output "eks_cluster_id" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "eks_cluster_certificate_authority_data"
  value       = module.eks.cluster_certificate_authority_data
}
