locals {
  create_irsa = try(var.addon_config.service_account_role_arn == "", true)

  cni_ipv6_policy = var.enable_ipv6 ? [aws_iam_policy.cni_ipv6_policy[0].arn] : []
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = "vpc-cni"
  addon_version            = try(var.addon_config.addon_version, null)
  resolve_conflicts        = try(var.addon_config.resolve_conflicts, "OVERWRITE")
  service_account_role_arn = local.create_irsa ? module.irsa_addon[0].irsa_iam_role_arn : try(var.addon_config.service_account_role_arn, null)
  preserve                 = try(var.addon_config.preserve, true)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}

module "irsa_addon" {
  source = "../../../modules/irsa"

  count = local.create_irsa ? 1 : 0

  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = "kube-system"
  kubernetes_service_account        = "aws-node"
  irsa_iam_role_path                = var.addon_context.irsa_iam_role_path
  irsa_iam_permissions_boundary     = var.addon_context.irsa_iam_permissions_boundary
  eks_cluster_id                    = var.addon_context.eks_cluster_id
  eks_oidc_provider_arn             = var.addon_context.eks_oidc_provider_arn
  irsa_iam_policies = concat(
    ["arn:${var.addon_context.aws_partition_id}:iam::aws:policy/AmazonEKS_CNI_Policy"],
    local.cni_ipv6_policy,
    try(var.addon_config.additional_iam_policies, [])
  )
}

resource "aws_iam_policy" "cni_ipv6_policy" {
  count = local.create_irsa && var.enable_ipv6 ? 1 : 0

  name        = "${var.addon_context.eks_cluster_id}-AmazonEKS_CNI_IPv6_Policy"
  description = "IAM policy for EKS CNI to assign IPV6 addresses"
  path        = try(var.addon_context.irsa_iam_role_path, null)
  policy      = data.aws_iam_policy_document.ipv6_policy[0].json

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}

data "aws_iam_policy_document" "ipv6_policy" {
  count = var.enable_ipv6 ? 1 : 0
  statement {
    sid = "IpV6"
    actions = [
      "ec2:AssignIpv6Addresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "CreateTags"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:${var.addon_context.aws_partition_id}:ec2:*:*:network-interface/*"]
  }
}
