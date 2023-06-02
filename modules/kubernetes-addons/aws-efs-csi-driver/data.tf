data "aws_iam_policy_document" "aws_efs_csi_driver" {
  statement {
    sid       = "AllowDescribeAvailabilityZones"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeAvailabilityZones",
    ]
  }

  statement {
    sid    = "AllowDescribeFileSystems"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:elasticfilesystem:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:file-system/*",
      "arn:${var.addon_context.aws_partition_id}:elasticfilesystem:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:access-point/*"
    ]

    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets"
    ]
  }

  statement {
    sid       = "AllowCreateAccessPoint"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:elasticfilesystem:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:file-system/*"]
    actions   = ["elasticfilesystem:CreateAccessPoint"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    sid       = "TagResource"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:elasticfilesystem:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:file-system/*"]
    actions   = ["elasticfilesystem:TagResource"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    sid       = "AllowDeleteAccessPoint"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:elasticfilesystem:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:access-point/*"]
    actions   = ["elasticfilesystem:DeleteAccessPoint"]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    sid    = "AllowTagResource"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:elasticfilesystem:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:file-system/*",
      "arn:${var.addon_context.aws_partition_id}:elasticfilesystem:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:access-point/*"
    ]
    actions = ["elasticfilesystem:TagResource"]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount",
    ]
    resources = ["arn:${var.addon_context.aws_partition_id}:elasticfilesystem:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:file-system/*"]
    condition {
      test     = "Bool"
      variable = "elasticfilesystem:AccessedViaMountTarget"
      values   = ["true"]
    }
  }
}
