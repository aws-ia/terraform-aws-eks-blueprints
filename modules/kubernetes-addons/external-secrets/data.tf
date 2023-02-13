data "aws_iam_policy_document" "external_secrets" {
  statement {
    actions = ["ssm:GetParameter"]
    resources = concat(
      var.external_secrets_ssm_parameter_arns,
      ["arn:${var.addon_context.aws_partition_id}:ssm:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:parameter/*"]
    )
  }

  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = concat(
      var.external_secrets_secrets_manager_arns,
      ["arn:${var.addon_context.aws_partition_id}:secretsmanager:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:secret:*"]
    )
  }
}
