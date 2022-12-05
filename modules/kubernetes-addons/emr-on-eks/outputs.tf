################################################################################
# Job Execution Role
################################################################################

output "job_execution_role_name" {
  description = "IAM role name of the job execution role"
  value       = try(aws_iam_role.this[0].name, "")
}

output "job_execution_role_arn" {
  description = "IAM role ARN of the job execution role"
  value       = try(aws_iam_role.this[0].arn, "")
}

output "job_execution_role_unique_id" {
  description = "Stable and unique string identifying the job execution IAM role"
  value       = try(aws_iam_role.this[0].unique_id, "")
}

################################################################################
# EMR Virtual Cluster
################################################################################

output "virtual_cluster_arn" {
  description = "ARN of the EMR virtual cluster"
  value       = aws_emrcontainers_virtual_cluster.this.arn
}

output "virtual_cluster_id" {
  description = "ID of the EMR virtual cluster"
  value       = aws_emrcontainers_virtual_cluster.this.id
}

################################################################################
# CloudWatch Log Group
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].name, "")
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = try(aws_cloudwatch_log_group.this[0].arn, "")
}
