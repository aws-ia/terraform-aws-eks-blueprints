output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_id}"
}

output "s3_bucket" {
  description = "S3 Bucket Name"
  value       = module.s3_bucket.s3_bucket_id
}
