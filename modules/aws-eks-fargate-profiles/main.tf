locals {
  create_iam_role = try(var.fargate_profile.create_iam_role, true)
}

resource "aws_eks_fargate_profile" "eks_fargate" {
  cluster_name           = var.context.eks_cluster_id
  fargate_profile_name   = var.fargate_profile.fargate_profile_name
  pod_execution_role_arn = local.create_iam_role ? aws_iam_role.fargate[0].arn : var.fargate_profile.iam_role_arn
  subnet_ids             = var.fargate_profile.subnet_ids

  tags = merge(
    {
      "kubernetes.io/cluster/${var.context.eks_cluster_id}" = "owned"
      "k8s.io/cluster/${var.context.eks_cluster_id}"        = "owned"
    },
    var.context.tags,
    try(var.fargate_profile.additional_tags, {}),
  )

  dynamic "selector" {
    for_each = toset(var.fargate_profile.fargate_profile_namespaces)
    content {
      namespace = selector.value.namespace
      labels    = try(selector.value.k8s_labels, null)
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate_pod_execution_role_policy,
  ]
}

data "aws_iam_policy_document" "fargate_assume_role_policy" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid = "EKSFargateAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "fargate" {
  count = local.create_iam_role ? 1 : 0

  name                  = "${var.context.eks_cluster_id}-${var.fargate_profile.fargate_profile_name}"
  description           = "EKS Fargate IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.fargate_assume_role_policy[0].json
  path                  = var.context.iam_role_path
  permissions_boundary  = var.context.iam_role_permissions_boundary
  force_detach_policies = true
  tags                  = var.context.tags
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_role_policy" {
  for_each = { for k, v in toset(concat(
    ["arn:${var.context.aws_partition_id}:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"],
    try(var.fargate_profile.additional_iam_policies, []))) : k => v if local.create_iam_role
  }

  policy_arn = each.key
  role       = aws_iam_role.fargate[0].name
}

data "aws_iam_policy_document" "cwlogs" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_policy" "cwlogs" {
  count = local.create_iam_role ? 1 : 0

  name        = "${var.context.eks_cluster_id}-${var.fargate_profile["fargate_profile_name"]}-cwlogs"
  description = "Allow fargate profiles to write logs to CloudWatch"
  path        = var.context.iam_role_path
  policy      = data.aws_iam_policy_document.cwlogs[0].json
  tags        = var.context.tags
}

resource "aws_iam_role_policy_attachment" "cwlogs" {
  count = local.create_iam_role ? 1 : 0

  policy_arn = aws_iam_policy.cwlogs[0].arn
  role       = aws_iam_role.fargate[0].name
}
