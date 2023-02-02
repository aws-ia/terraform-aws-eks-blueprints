locals {
  name = "kube-proxy"
}

data "aws_eks_addon_version" "this" {
  addon_name         = local.name
  kubernetes_version = var.addon_config.kubernetes_version
  most_recent        = try(var.addon_config.most_recent, false)
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = local.name
  addon_version            = try(var.addon_config.addon_version, data.aws_eks_addon_version.this.version)
  resolve_conflicts        = try(var.addon_config.resolve_conflicts, "OVERWRITE")
  service_account_role_arn = try(var.addon_config.service_account_role_arn, null)
  preserve                 = try(var.addon_config.preserve, true)
  configuration_values     = try(var.addon_config.configuration_values, null)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}
