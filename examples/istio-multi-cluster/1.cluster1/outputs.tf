output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "istio-reader-token" {
  description = "Istio token for cross cluster auth"
  value       = data.kubernetes_secret.istio_reader.data["token"]
  sensitive   = true
}
output "istio-reader-cacert" {
  description = "Istio token for cross cluster auth"
  value       = data.kubernetes_secret.istio_reader.data["ca.crt"]
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Cluster ca certificate"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.eks.cluster_name
}


output "cluster_region" {
  description = "Cluster region"
  value       = local.region
}

