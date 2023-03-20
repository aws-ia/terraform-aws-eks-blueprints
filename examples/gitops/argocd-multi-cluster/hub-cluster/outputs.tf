output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region} --profile ${var.hub_profile}"
}
output "argocd_login" {
  description = "ArgoCD CLI login command"
  value       = var.enable_ingress ? "argocd login ${var.argocd_subdomain}.${var.domain_name} --username admin" : "argocd login $(kubectl get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') --username admin --insecure"
}
