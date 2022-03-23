resource "aws_prometheus_workspace" "amp_workspace" {
  alias = local.amazon_prometheus_workspace_alias
}
