output "platform_teams_iam_role_arn" {
  description = "IAM role ARN for Platform Teams"
  value = tomap({
    for k, v in aws_iam_role.platform_team : k => v.arn
  })
}

output "application_teams_iam_role_arn" {
  description = "IAM role ARN for Teams"
  value = tomap({
    for k, v in aws_iam_role.team_access : k => v.arn
  })
}

output "team_sa_irsa_iam_role_arn" {
  description = "IAM role ARN for Teams EKS Service Account (IRSA)"
  value = tomap({
    for k, v in aws_iam_role.team_sa_irsa : k => v.arn
  })
}
