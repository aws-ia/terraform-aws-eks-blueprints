output "postgres_db_name" {
  value = module.rds-aurora.aurora_cluster_database_name
}

output "postgres_host" {
  value = module.rds-aurora.aurora_cluster_instance_endpoints
}

output "postgres_port" {
  value = module.rds-aurora.aurora_cluster_port
}

output "postgres_username" {
  value = module.rds-aurora.aurora_cluster_master_username
}

output "postgres_password" {
  value     = module.rds-aurora.aurora_cluster_master_password
  sensitive = true
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}