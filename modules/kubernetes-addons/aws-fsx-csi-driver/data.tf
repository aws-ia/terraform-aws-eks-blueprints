data "aws_iam_policy_document" "aws_fsx_csi_driver" {
  statement {
    sid       = "AllowCreateServiceLinkedRoles"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:iam::*:role/aws-service-role/s3.data-source.lustre.fsx.amazonaws.com/*"]

    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
    ]
  }

  statement {
    sid       = "AllowCreateServiceLinkedRole"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:iam::${var.addon_context.aws_caller_identity_account_id}:role/*"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["fsx.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowListBuckets"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:s3:::*"]

    actions = [
      "s3:ListBucket"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:fsx:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:file-system/*"]

    actions = [
      "fsx:CreateFileSystem",
      "fsx:DeleteFileSystem",
      "fsx:UpdateFileSystem",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:fsx:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:*"]

    actions = [
      "fsx:DescribeFileSystems",
      "fsx:TagResource"
    ]
  }
}
