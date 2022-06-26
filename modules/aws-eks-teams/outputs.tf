output "platform_teams_iam_role_arn" {
  description = "IAM role ARN for Platform Teams"
  value = tomap({
    for k, v in aws_iam_role.platform_team_iam_role : k => v.arn
  })
}

output "application_teams_iam_role_arn" {
  description = "IAM role ARN for Application Teams"
  value = tomap({
    for k, v in aws_iam_role.application_team_iam_role : k => v.arn
  })
}

output "application_team_sa_irsa_name" {
  description = "IAM role name for Application Teams EKS Service Account (IRSA)"
  value = tomap({
    for k, v in aws_iam_role.application_team_sa_irsa : k => v.name
  })
}

output "application_team_sa_irsa_arn" {
  description = "IAM role ARN for Application Teams EKS Service Account (IRSA)"
  value = tomap({
    for k, v in aws_iam_role.application_team_sa_irsa : k => v.arn
  })
}

output "platform_teams_configure_kubectl" {
  description = "Configure kubectl for each Platform Team: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value = tomap({
    for k, v in aws_iam_role.platform_team_iam_role : k => "aws eks --region ${data.aws_region.current.id} update-kubeconfig --name ${data.aws_eks_cluster.eks_cluster.name}  --role-arn ${v.arn}"
  })
}

output "application_teams_configure_kubectl" {
  description = "Configure kubectl for each Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value = tomap({
    for k, v in aws_iam_role.application_team_iam_role : k => "aws eks --region ${data.aws_region.current.id} update-kubeconfig --name ${data.aws_eks_cluster.eks_cluster.name}  --role-arn ${v.arn}"
  })
}
