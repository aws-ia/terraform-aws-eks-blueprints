output "amazon_prometheus_workspace_id" {
  description = "Amazon Managed Prometheus Workspace ID"
  value       = aws_prometheus_workspace.amp_workspace.id
}

output "amazon_prometheus_workspace_arn" {
  description = "Amazon Managed Prometheus Workspace ARN"
  value       = aws_prometheus_workspace.amp_workspace.arn
}

output "amazon_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus Workspace Endpoint"
  value       = aws_prometheus_workspace.amp_workspace.prometheus_endpoint
}
