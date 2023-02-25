output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? local.argocd_gitops_config : null
}

output "release_metadata" {
  description = "Map of attributes of the Helm release metadata"
  value       = module.helm_addon.release_metadata
}

output "irsa_arn" {
  description = "IAM role ARN for the service account"
  value       = module.helm_addon.irsa_arn
}

output "irsa_name" {
  description = "IAM role name for the service account"
  value       = module.helm_addon.irsa_name
}

output "service_account" {
  description = "Name of Kubernetes service account"
  value       = module.helm_addon.service_account
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = try(aws_sqs_queue.this[0].arn, null)
}

output "sqs_queue_name" {
  description = "The name of the created Amazon SQS queue"
  value       = try(aws_sqs_queue.this[0].name, null)
}

output "sqs_queue_url" {
  description = "The URL for the created Amazon SQS queue"
  value       = try(aws_sqs_queue.this[0].url, null)
}

output "event_rules" {
  description = "Map of the event rules created and their attributes"
  value       = aws_cloudwatch_event_rule.this
}
