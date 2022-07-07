resource "aws_eks_addon" "kube_proxy" {
  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = "kube-proxy"
  addon_version            = try(var.addon_config.addon_version, null)
  resolve_conflicts        = try(var.addon_config.resolve_conflicts, "OVERWRITE")
  service_account_role_arn = try(var.addon_config.service_account_role_arn, null)
  preserve                 = try(var.addon_config.preserve, true)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}
