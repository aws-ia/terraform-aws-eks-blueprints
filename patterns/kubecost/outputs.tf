output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name}"
}

output "cur_bucket_id" {
  description = "Kubecost CUR bucket id"
  value       = aws_s3_bucket.cur.id
}

output "s3_cur_report_prefix" {
  description = "Kubecost CUR bucket prefix"
  value       = aws_cur_report_definition.cur.s3_prefix
}

output "region" {
  description = "region"
  value       = var.region
}
