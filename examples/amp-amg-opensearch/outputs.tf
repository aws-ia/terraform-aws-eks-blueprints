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

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}
