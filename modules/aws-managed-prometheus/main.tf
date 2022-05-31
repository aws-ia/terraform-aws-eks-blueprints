
resource "aws_prometheus_workspace" "amp_workspace" {
  alias = var.amazon_prometheus_workspace_alias == null ? format("%s-%s", "amp-ws", var.eks_cluster_id) : var.amazon_prometheus_workspace_alias

  tags = var.tags
}

resource "aws_prometheus_rule_group_namespace" "rules" {
  count = var.amazon_prometheus_rule_group_data == null ? 0 : 1

  name         = "rules"
  workspace_id = aws_prometheus_workspace.amp_workspace.id
  data         = var.amazon_prometheus_rule_group_data
}

resource "aws_prometheus_alert_manager_definition" "alerts" {
  count = var.amazon_prometheus_alert_manager_definition == null ? 0 : 1

  workspace_id = aws_prometheus_workspace.amp_workspace.id
  definition   = var.amazon_prometheus_alert_manager_definition
}
