output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "eks_oidc_provider_arn" {
  description = "eks_oidc_provider_arn"
  value       = module.eks_blueprints.eks_oidc_provider_arn
}

output "amp_ingest_role_arn" {
  description = "use it to replace <your eks cluster amp-ingest-irsa role> in  adot-collector-fargate.yaml "
  value       = aws_iam_role.amp_ingest_role.arn
}

output "amp_remotewriter_endpoint" {
  description = "Amazon managed prometheus remotewriter endpoint. use it to replace <your amp remote write endpoint> in  adot-collector-fargate.yaml"
  value       = "${module.managed_prometheus.workspace_prometheus_endpoint}api/v1/remote_write"
}

output "opensearch_domain" {
  description = "Amazon Openseach domain. use it to replace <your opensearch domain> in fargate-cm.yaml"
  value       = resource.aws_elasticsearch_domain.opensearch.endpoint
}
output "opensearch_dashboard_url" {
  description = "opensearch_dashboard_url"
  value       = "https://${resource.aws_elasticsearch_domain.opensearch.endpoint}/_dashboards"
}
output "your_region" {
  description = "the region you use"
  value       = local.region
}
