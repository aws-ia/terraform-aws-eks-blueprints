
resource "aws_eks_addon" "kube_proxy" {
  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = local.add_on_config["addon_name"]
  addon_version            = local.add_on_config["addon_version"]
  resolve_conflicts        = local.add_on_config["resolve_conflicts"]
  service_account_role_arn = local.add_on_config["service_account_role_arn"]
  tags = merge(
    var.addon_context.tags, local.add_on_config["tags"],
    { "eks_addon" = "kube-proxy" }
  )

}
