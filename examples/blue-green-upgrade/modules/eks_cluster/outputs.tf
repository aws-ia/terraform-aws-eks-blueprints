output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

# output "configure_kubectl" {
#   description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
#   value       = module.eks.configure_kubectl
# }

output "eks_blueprints_admin_team_configure_kubectl" {
  description = "Configure kubectl for each Platform Team: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}  --role-arn ${module.eks_blueprints_admin_team.iam_role_arn}"
}

output "eks_blueprints_platform_teams_configure_kubectl" {
  description = "Configure kubectl for each Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = [for team in module.eks_blueprints_platform_teams : "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}  --role-arn ${team.iam_role_arn}"]
}

output "eks_blueprints_dev_teams_configure_kubectl" {
  description = "Configure kubectl for each Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = [for team in module.eks_blueprints_dev_teams : "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}  --role-arn ${team.iam_role_arn}"]
}

output "eks_blueprints_ecsdemo_teams_configure_kubectl" {
  description = "Configure kubectl for each Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = [for team in module.eks_blueprints_ecsdemo_teams : "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}  --role-arn ${team.iam_role_arn}"]
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "cluster_certificate_authority_data"
  value       = module.eks.cluster_certificate_authority_data
}
