output "efs_file_system_id" {
  description = "ID of the EFS file system to use for creating a storage class"
  value       = aws_efs_file_system.efs.id
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}
