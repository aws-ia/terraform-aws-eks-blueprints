output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.spoke_cluster.configure_kubectl
}

# Teams kubeconfig
output "configure_kubectl_team_frontend" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.spoke_cluster.configure_kubectl_team_frontend
}
output "configure_kubectl_team_nodejs" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.spoke_cluster.configure_kubectl_team_nodejs
}
output "configure_kubectl_team_crystal" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.spoke_cluster.configure_kubectl_team_crystal
}
