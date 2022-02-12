output "opensearch_pw" {
  description = "Amazon OpenSearch Service Domain password"
  value       = var.opensearch_dashboard_pw
  sensitive   = true
}

output "opensearch_user" {
  description = "Amazon OpenSearch Service Domain username"
  value       = var.opensearch_dashboard_user
}

output "opensearch_vpc_endpoint" {
  description = "Amazon OpenSearch Service Domain-specific endpoint"
  value       = aws_elasticsearch_domain.opensearch.endpoint
}

output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}
