output "eks_blueprints_admin_team_configure_kubectl" {
  description = "Configure kubectl for each Platform Team: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}  --role-arn ${module.eks_blueprints_admin_team.iam_role_arn}"
}

output "eks_blueprints_dev_teams_configure_kubectl" {
  description = "Configure kubectl for each Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = [for team in module.eks_blueprints_dev_teams : "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}  --role-arn ${team.iam_role_arn}"]
}
