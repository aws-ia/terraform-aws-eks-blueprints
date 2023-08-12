# output "configure_kubectl_shared" {
#   description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
#   value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.shared_cluster.cluster_name}"
# }
# output "configure_kubectl_tenant" {
#   description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
#   value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.tenant_cluster.cluster_name}"
# }

output "istio_token_shared" {
  description = "istio-token"
  value       = module.shared_cluster.istio-reader-token
  sensitive   = true
}
output "istio_token_tenant" {
  description = "istio-token"
  value       = module.tenant_cluster.istio-reader-token
  sensitive   = true
}
output "configure_kubectl_tenant" {
  description = "istio-token"
  value       = module.tenant_cluster.configure_kubectl
}
