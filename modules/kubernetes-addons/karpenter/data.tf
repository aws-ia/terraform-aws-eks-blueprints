data "aws_partition" "current" {}

data "aws_iam_policy_document" "karpenter" {
  statement {
    sid       = "AllowEc2DescribeActions"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
    ]
  }

  statement {
    sid    = "AllowEc2Actions"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:ec2:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:*",
      "arn:${var.addon_context.aws_partition_id}:ec2:${var.addon_context.aws_region_name}::image/*"
    ]

    actions = [
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateTags",
      "ec2:DeleteLaunchTemplate",
      "ec2:RunInstances"
    ]
  }

  statement {
    sid       = "AllowPassRole"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:iam::${var.addon_context.aws_caller_identity_account_id}:role/*"]

    actions = [
      "iam:PassRole",
    ]
  }

  statement {
    sid       = "AllowGetPrice"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "pricing:GetProducts",
    ]
  }

  statement {
    sid       = "AllowGetParameters"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:ssm:${var.addon_context.aws_region_name}::parameter/*"]

    actions = [
      "ssm:GetParameter",
    ]
  }

  statement {
    actions   = ["eks:DescribeCluster"]
    resources = ["arn:${var.addon_context.aws_partition_id}:eks:*:${var.addon_context.aws_caller_identity_account_id}:cluster/${var.addon_context.eks_cluster_id}"]
  }

  statement {
    sid       = "ConditionalEC2Termination"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:ec2:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:instance/*"]
    actions   = ["ec2:TerminateInstances"]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"
      values   = ["*karpenter*"]
    }
  }

  dynamic "statement" {
    for_each = var.enable_spot_termination ? [1] : []

    content {
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage",
      ]
      resources = [aws_sqs_queue.this[0].arn]
    }
  }
}

data "aws_iam_policy_document" "sqs_queue" {
  count = var.enable_spot_termination ? 1 : 0

  statement {
    sid     = "SqsWrite"
    actions = ["sqs:SendMessage"]
    principals {
      type = "Service"
      identifiers = [
        "events.${local.dns_suffix}",
        "sqs.${local.dns_suffix}"
      ]
    }
    resources = [aws_sqs_queue.this[0].arn]
  }
}
