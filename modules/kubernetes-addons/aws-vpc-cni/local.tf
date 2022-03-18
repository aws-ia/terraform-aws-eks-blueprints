locals {
  default_add_on_config = {
    addon_name               = "vpc-cni"
    addon_version            = "v1.10.2-eksbuild.1"
    service_account          = "aws-node"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
  add_on_config = merge(
    local.default_add_on_config,
    var.add_on_config
  )

  cni_ipv6_policy = var.enable_ipv6 ? [aws_iam_policy.cni_ipv6_policy[0].arn] : []

  irsa_iam_policies = concat(
    ["arn:${var.addon_context.aws_partition_id}:iam::aws:policy/AmazonEKS_CNI_Policy"],
    local.cni_ipv6_policy,
    local.add_on_config["additional_iam_policies"]
  )
}
