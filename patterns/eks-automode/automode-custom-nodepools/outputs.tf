################################################################################
# EKS Managed Node Group
################################################################################

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

################################################################################
# AMP
################################################################################
output "grafana_login" {
  description = "Get grafana password for user: admin. Port-forward grafana with command: kubectl port-forward svc/kube-prometheus-stack-grafana 8080:80 -n kube-prometheus-stack"
  value       = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.grafana.name} --region ${local.region} --query SecretString --output text"
}

output "grafana_portforward" {
  description = "Port-forward grafana with command: "
  value       = "kubectl port-forward svc/kube-prometheus-stack-grafana 8080:80 -n kube-prometheus-stack"
}