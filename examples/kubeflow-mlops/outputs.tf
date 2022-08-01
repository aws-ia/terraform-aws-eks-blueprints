output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}


output "eks_oidc_provider_arn" {
  description = "eks_oidc_provider_arn"
  value       = module.eks_blueprints.eks_oidc_provider_arn
}


output "cluster_vpc_id" {
  description = "cluster_vpc_id"
  value       = module.vpc.vpc_id
}
