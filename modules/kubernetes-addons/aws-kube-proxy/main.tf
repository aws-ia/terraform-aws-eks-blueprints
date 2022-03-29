resource "aws_eks_addon" "kube_proxy" {
  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = local.addon_config["addon_name"]
  addon_version            = local.addon_config["addon_version"]
  resolve_conflicts        = local.addon_config["resolve_conflicts"]
  service_account_role_arn = local.addon_config["service_account_role_arn"]
  tags = merge(
    var.addon_context.tags, local.addon_config["tags"],
    { "eks_addon" = "kube-proxy" }
  )
}
