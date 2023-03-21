output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region} --profile ${var.spoke_profile}"
}

# Teams kubeconfig
output "configure_kubectl_team_frontend" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region} --profile ${var.spoke_profile} --role-arn ${module.app_teams["frontend"].aws_auth_configmap_role.rolearn}"
}
output "configure_kubectl_team_nodejs" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region} --profile ${var.spoke_profile} --role-arn ${module.app_teams["nodejs"].aws_auth_configmap_role.rolearn}"
}
output "configure_kubectl_team_crystal" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region} --profile ${var.spoke_profile} --role-arn ${module.app_teams["crystal"].aws_auth_configmap_role.rolearn}"
}
