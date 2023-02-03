data "aws_iam_policy_document" "external_secrets" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = var.external_secrets_ssm_parameter_arns
  }

  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = var.external_secrets_secrets_manager_arns
  }
}
