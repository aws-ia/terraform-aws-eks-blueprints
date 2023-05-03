variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the cluster OIDC Provider"
  type        = string
}

variable "create_delay_duration" {
  description = "The duration to wait before creating resources"
  type        = string
  default     = "30s"
}

variable "create_delay_dependencies" {
  description = "Dependency attribute which must be resolved before starting the `create_delay_duration`"
  type        = list(string)
  default     = []
}

################################################################################
# Argo Rollouts
################################################################################

variable "enable_argo_rollouts" {
  description = "Enable Argo Rollouts add-on"
  type        = bool
  default     = false
}

variable "argo_rollouts" {
  description = "Argo Rollouts addon configuration values"
  type        = any
  default     = {}
}

################################################################################
# Argo Workflows
################################################################################

variable "enable_argo_workflows" {
  description = "Enable Argo workflows add-on"
  type        = bool
  default     = false
}

variable "argo_workflows" {
  description = "Argo Workflows addon configuration values"
  type        = any
  default     = {}
}

################################################################################
# ArgoCD
################################################################################

variable "enable_argocd" {
  description = "Enable Argo CD Kubernetes add-on"
  type        = bool
  default     = false
}

variable "argocd" {
  description = "ArgoCD addon configuration values"
  type        = any
  default     = {}
}

################################################################################
# AWS Cloudwatch Metrics
################################################################################

variable "enable_aws_cloudwatch_metrics" {
  description = "Enable AWS Cloudwatch Metrics add-on for Container Insights"
  type        = bool
  default     = false
}

variable "aws_cloudwatch_metrics" {
  description = "Cloudwatch Metrics addon configuration values"
  type        = any
  default     = {}
}

################################################################################
# AWS EFS CSI Driver
################################################################################

variable "enable_aws_efs_csi_driver" {
  description = "Enable AWS EFS CSI Driver add-on"
  type        = bool
  default     = false
}

variable "aws_efs_csi_driver" {
  description = "EFS CSI Driver addon configuration values"
  type        = any
  default     = {}
}

################################################################################
# AWS for Fluentbit
################################################################################

variable "enable_aws_for_fluentbit" {
  description = "Enable AWS for FluentBit add-on"
  type        = bool
  default     = false
}

variable "aws_for_fluentbit" {
  description = "AWS Fluentbit add-on configurations"
  type        = any
  default     = {}
}

variable "aws_for_fluentbit_cw_log_group" {
  description = "AWS Fluentbit CloudWatch Log Group configurations"
  type        = any
  default     = {}
}

################################################################################
# AWS FSx CSI Driver
################################################################################

variable "enable_aws_fsx_csi_driver" {
  description = "Enable AWS FSX CSI Driver add-on"
  type        = bool
  default     = false
}

variable "aws_fsx_csi_driver" {
  description = "FSX CSI Driver addon configuration values"
  type        = any
  default     = {}
}

################################################################################
# AWS Load Balancer Controller
################################################################################

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller add-on"
  type        = bool
  default     = false
}

variable "aws_load_balancer_controller" {
  description = "AWS Load Balancer Controller addon configuration values"
  type        = any
  default     = {}
}

################################################################################
# AWS Node Termination Handler
################################################################################

variable "enable_aws_node_termination_handler" {
  description = "Enable AWS Node Termination Handler add-on"
  type        = bool
  default     = false
}

variable "aws_node_termination_handler" {
  description = "AWS Node Termination Handler addon configuration values"
  type        = any
  default     = {}
}

variable "aws_node_termination_handler_sqs" {
  description = "AWS Node Termination Handler SQS queue configuration values"
  type        = any
  default     = {}
}

variable "aws_node_termination_handler_asg_arns" {
  description = "List of Auto Scaling group ARNs that AWS Node Termination Handler will monitor for EC2 events"
  type        = list(string)
  default     = []
}

################################################################################
# AWS Private CA Issuer
################################################################################

variable "enable_aws_privateca_issuer" {
  description = "Enable AWS PCA Issuer"
  type        = bool
  default     = false
}

variable "aws_privateca_issuer" {
  description = "AWS PCA Issuer add-on configurations"
  type        = any
  default     = {}
}

################################################################################
# Cert Manager
################################################################################

variable "enable_cert_manager" {
  description = "Enable cert-manager add-on"
  type        = bool
  default     = false
}

variable "cert_manager" {
  description = "cert-manager addon configuration values"
  type        = any
  default     = {}
}

variable "cert_manager_route53_hosted_zone_arns" {
  description = "List of Route53 Hosted Zone ARNs that are used by cert-manager to create DNS records"
  type        = list(string)
  default     = ["arn:aws:route53:::hostedzone/*"]
}

################################################################################
# Cluster Autoscaler
################################################################################

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster autoscaler add-on"
  type        = bool
  default     = false
}

variable "cluster_autoscaler" {
  description = "Cluster Autoscaler addon configuration values"
  type        = any
  default     = {}
}

################################################################################
# Cluster Proportional Autoscaler
################################################################################

variable "enable_cluster_proportional_autoscaler" {
  description = "Enable Cluster Proportional Autoscaler"
  type        = bool
  default     = false
}

variable "cluster_proportional_autoscaler" {
  description = "Cluster Proportional Autoscaler add-on configurations"
  type        = any
  default     = {}
}

################################################################################
# EKS Addons
################################################################################

variable "eks_addons" {
  description = "Map of EKS addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default     = {}
}

variable "eks_addons_timeouts" {
  description = "Create, update, and delete timeout configurations for the EKS addons"
  type        = map(string)
  default     = {}
}

################################################################################
# External DNS
################################################################################

variable "enable_external_dns" {
  description = "Enable external-dns operator add-on"
  type        = bool
  default     = false
}

variable "external_dns" {
  description = "external-dns addon configuration values"
  type        = any
  default     = {}
}

variable "external_dns_route53_zone_arns" {
  description = "List of Route53 zones ARNs which external-dns will have access to create/manage records (if using Route53)"
  type        = list(string)
  default     = []
}

################################################################################
# External Secrets
################################################################################

variable "enable_external_secrets" {
  description = "Enable External Secrets operator add-on"
  type        = bool
  default     = false
}

variable "external_secrets" {
  description = "External Secrets addon configuration values"
  type        = any
  default     = {}
}

variable "external_secrets_ssm_parameter_arns" {
  description = "List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:ssm:*:*:parameter/*"]
}

variable "external_secrets_secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
}

variable "external_secrets_kms_key_arns" {
  description = "List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:kms:*:*:key/*"]
}

################################################################################
# Fargate Fluentbit
################################################################################

variable "enable_fargate_fluentbit" {
  description = "Enable Fargate FluentBit add-on"
  type        = bool
  default     = false
}

variable "fargate_fluentbit_cw_log_group" {
  description = "AWS Fargate Fluentbit CloudWatch Log Group configurations"
  type        = any
  default     = {}
}

variable "fargate_fluentbit" {
  description = "Fargate fluentbit add-on config"
  type        = any
  default     = {}
}

################################################################################
# Gatekeeper
################################################################################

variable "enable_gatekeeper" {
  description = "Enable Gatekeeper add-on"
  type        = bool
  default     = false
}

variable "gatekeeper" {
  description = "Gatekeeper add-on configuration"
  type        = bool
  default     = false
}

################################################################################
# Ingress Nginx
################################################################################

variable "enable_ingress_nginx" {
  description = "Enable Ingress Nginx"
  type        = bool
  default     = false
}

variable "ingress_nginx" {
  description = "Ingress Nginx add-on configurations"
  type        = any
  default     = {}
}

################################################################################
# Karpenter
################################################################################

variable "enable_karpenter" {
  description = "Enable Karpenter controller add-on"
  type        = bool
  default     = false
}

variable "karpenter" {
  description = "Karpenter addon configuration values"
  type        = any
  default     = {}
}

variable "karpenter_enable_spot_termination" {
  description = "Determines whether to enable native node termination handling"
  type        = bool
  default     = true
}

variable "karpenter_sqs" {
  description = "Karpenter SQS queue for native node termination handling configuration values"
  type        = any
  default     = {}
}

variable "karpenter_node" {
  description = "Karpenter IAM role and IAM instance profile configuration values"
  type        = any
  default     = {}
}

################################################################################
# Kube Prometheus Stack
################################################################################

variable "enable_kube_prometheus_stack" {
  description = "Enable Kube Prometheus Stack"
  type        = bool
  default     = false
}

variable "kube_prometheus_stack" {
  description = "Kube Prometheus Stack add-on configurations"
  type        = any
  default     = {}
}

################################################################################
# Metrics Server
################################################################################

variable "enable_metrics_server" {
  description = "Enable metrics server add-on"
  type        = bool
  default     = false
}

variable "metrics_server" {
  description = "Metrics Server add-on configurations"
  type        = any
  default     = {}
}

################################################################################
# Secrets Store CSI Driver
################################################################################

variable "enable_secrets_store_csi_driver" {
  description = "Enable CSI Secrets Store Provider"
  type        = bool
  default     = false
}

variable "secrets_store_csi_driver" {
  description = "CSI Secrets Store Provider add-on configurations"
  type        = any
  default     = {}
}

################################################################################
# CSI Secrets Store Provider AWS
################################################################################

variable "enable_secrets_store_csi_driver_provider_aws" {
  description = "Enable AWS CSI Secrets Store Provider"
  type        = bool
  default     = false
}

variable "secrets_store_csi_driver_provider_aws" {
  description = "CSI Secrets Store Provider add-on configurations"
  type        = any
  default     = {}
}

################################################################################
# Velero
################################################################################

variable "enable_velero" {
  description = "Enable Kubernetes Dashboard add-on"
  type        = bool
  default     = false
}

variable "velero" {
  description = "Velero addon configuration values"
  type        = any
  default     = {}
}

################################################################################
# Vertical Pod Autoscaler
################################################################################

variable "enable_vpa" {
  description = "Enable Vertical Pod Autoscaler add-on"
  type        = bool
  default     = false
}

variable "vpa" {
  description = "Vertical Pod Autoscaler addon configuration values"
  type        = any
  default     = {}
}
