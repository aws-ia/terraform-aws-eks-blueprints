resource "aws_prometheus_workspace" "amp_workspace" {
  alias = var.amazon_prometheus_workspace_alias == null ? format("%s-%s", "amp-ws", var.eks_cluster_id) : var.amazon_prometheus_workspace_alias

  tags = var.tags
}
