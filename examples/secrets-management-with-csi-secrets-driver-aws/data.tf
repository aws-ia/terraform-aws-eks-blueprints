data "aws_iam_policy_document" "secrets_management_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = local.all_secret_arn
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
  }
} 