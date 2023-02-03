data "aws_iam_session_context" "current" {
  arn = var.addon_context.aws_caller_identity_arn
}

data "aws_iam_policy_document" "irsa" {
  statement {
    sid       = "PutLogEvents"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:logs:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:log-group:*:log-stream:*"]
    actions   = ["logs:PutLogEvents"]
  }

  statement {
    sid       = "CreateCWLogs"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:logs:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:log-group:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

data "aws_iam_policy_document" "kms" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type = "AWS"
      identifiers = ["arn:${var.addon_context.aws_partition_id}:iam::${var.addon_context.aws_caller_identity_account_id}:root",
      data.aws_iam_session_context.current.issuer_arn]
    }
  }

  statement {
    sid       = "Enable Encryption for LogGroup"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Decrypt*",
      "kms:Describe*",
      "kms:Encrypt*",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:${var.addon_context.aws_partition_id}:logs:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:log-group:${local.log_group_name}"]
    }

    principals {
      type        = "Service"
      identifiers = ["logs.${var.addon_context.aws_region_name}.amazonaws.com"]
    }
  }
}
