output "eks_blueprints_output" {
  description = "EKS Blueprints module outputs"
  value       = module.eks_blueprints
}

output "platform_teams_configure_kubectl" {
  description = "Configure kubectl for each Platform Team: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.teams[0].platform_teams_configure_kubectl
}

output "application_teams_configure_kubectl" {
  description = "Configure kubectl for each Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.teams[0].application_teams_configure_kubectl
}
