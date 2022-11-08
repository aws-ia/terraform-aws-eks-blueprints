data "aws_iam_policy_document" "karpenter" {
  statement {
    sid       = "KarpenterControllerPolicy"
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
    sid       = "KarpenterConditionalEC2Termination"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:TerminateInstances"]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"
      values   = ["*karpenter*"]
    }
  }

  statement {
    sid       = "KarpenterEventPolicyEvents"
    effect    = "Allow"
    resources = ["arn:aws:events:us-east-1:360093697111:rule/Karpenter-*"]

    actions = [
      "events:TagResource",
      "events:DeleteRule",
      "events:PutTargets",
      "events:PutRule",
      "events:ListTagsForResource",
      "events:RemoveTargets",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/karpenter.sh/discovery"
      values   = ["${ClusterName}"]
    }
  }

  statement {
    sid       = "KarpenterEventPolicyListRules"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["events:ListRules"]
  }

  statement {
    sid       = "KarpenterEventPolicySQS"
    effect    = "Allow"
    resources = ["arn:aws:sqs:us-east-1:360093697111:${ClusterName}"]

    actions = [
      "sqs:DeleteMessage",
      "sqs:TagQueue",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
      "sqs:CreateQueue",
      "sqs:SetQueueAttributes",
    ]
  }
}
