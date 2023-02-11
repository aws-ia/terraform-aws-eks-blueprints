data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeInstanceTypes",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.addon_context.eks_cluster_id}"
      values   = ["owned"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:autoscaling:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:autoScalingGroup:*"]

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.addon_context.eks_cluster_id}"
      values   = ["owned"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:eks:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:nodegroup/${var.addon_context.eks_cluster_id}/*"]

    actions = [
      "eks:DescribeNodegroup",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.addon_context.eks_cluster_id}"
      values   = ["owned"]
    }
  }
}
