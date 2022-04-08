output "ssp_output" {
  description = "SSP module outputs"
  value       = module.aws-eks-accelerator-for-terraform
}

output "platform_teams_configure_kubectl" {
  description = "Configure kubectl for each Platform Team: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.aws-eks-accelerator-for-terraform.teams[0].platform_teams_configure_kubectl
}

output "application_teams_configure_kubectl" {
  description = "Configure kubectl for each Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.aws-eks-accelerator-for-terraform.teams[0].application_teams_configure_kubectl
}
