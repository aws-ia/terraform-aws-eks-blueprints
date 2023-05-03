output "argo_rollouts" {
  description = "Map of attributes of the Helm release created"
  value       = module.argo_rollouts
}

output "argo_workflows" {
  description = "Map of attributes of the Helm release created"
  value       = module.argo_workflows
}

output "argocd" {
  description = "Map of attributes of the Helm release created"
  value       = module.argocd
}

output "aws_cloudwatch_metrics" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_cloudwatch_metrics
}

output "aws_efs_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_efs_csi_driver
}

output "aws_for_fluentbit" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_for_fluentbit
}

output "aws_fsx_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_fsx_csi_driver
}

output "aws_load_balancer_controller" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_load_balancer_controller
}

output "aws_node_termination_handler" {
  description = "Map of attributes of the Helm release and IRSA created"
  value = merge(
    module.aws_node_termination_handler,
    {
      sqs = module.aws_node_termination_handler_sqs
    }
  )
}

output "aws_privateca_issuer" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_privateca_issuer
}

output "cert_manager" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.cert_manager
}

output "cluster_autoscaler" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.cluster_autoscaler
}

output "cluster_proportional_autoscaler" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.cluster_proportional_autoscaler
}

output "eks_addons" {
  description = "Map of attributes for each EKS addons enabled"
  value       = aws_eks_addon.this
}

output "external_dns" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.external_dns
}

output "external_secrets" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.external_secrets
}

output "fargate_fluentbit" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = kubernetes_config_map_v1.aws_logging
}

output "gatekeeper" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.gatekeeper
}

output "ingress_nginx" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.ingress_nginx
}

output "karpenter" {
  description = "Map of attributes of the Helm release and IRSA created"
  value = merge(
    module.karpenter,
    {
      node_instance_profile_name = try(aws_iam_instance_profile.karpenter[0].name, "")
      node_iam_role_arn          = try(aws_iam_role.karpenter[0].arn, "")
      sqs                        = module.karpenter_sqs
    }
  )
}

output "kube_prometheus_stack" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.kube_prometheus_stack
}

output "metrics_server" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.metrics_server
}

output "secrets_store_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.secrets_store_csi_driver
}

output "secrets_store_csi_driver_provider_aws" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.secrets_store_csi_driver_provider_aws
}

output "velero" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.velero
}

output "vpa" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.vpa
}
