output "opensearch_pw" {
  description = "Amazon OpenSearch Service Domain password"
  value       = var.opensearch_dashboard_pw
  sensitive   = true
}

output "opensearch_user" {
  description = "Amazon OpenSearch Service Domain username"
  value       = var.opensearch_dashboard_user
}

output "opensearch_domain_endpoint" {
  description = "Amazon OpenSearch Service Domain-specific endpoint"
  value       = aws_elasticsearch_domain.opensearch.endpoint
}

output "amazon_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus Workspace Endpoint"
  value       = module.aws-eks-accelerator-for-terraform.amazon_prometheus_workspace_endpoint
}