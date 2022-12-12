data "aws_arn" "queue" {
  count = var.sqs_queue_arn != "" ? 1 : 0

  arn = var.sqs_queue_arn
}

data "aws_iam_policy_document" "karpenter" {
  statement {
    sid       = "Karpenter"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateTags",
      "ec2:DeleteLaunchTemplate",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "ec2:RunInstances",
      "iam:PassRole",
      "pricing:GetProducts",
      "ssm:GetParameter",
    ]
  }

  statement {
    sid       = "ConditionalEC2Termination"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:TerminateInstances"]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"
      values   = ["*karpenter*"]
    }
  }

  dynamic "statement" {
    for_each = var.sqs_queue_arn != "" ? [1] : []

    content {
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage",
      ]
      resources = [var.sqs_queue_arn]
    }
  }
}
