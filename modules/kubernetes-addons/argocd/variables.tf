variable "helm_config" {
  type        = any
  default     = {}
  description = "ArgoCD Helm Chart Config values"
}

variable "applications" {
  type        = any
  default     = {}
  description = "ArgoCD Application config used to bootstrap a cluster."
}

variable "admin_password_secret_name" {
  type        = string
  default     = ""
  description = "Name for a secret stored in AWS Secrets Manager that contains the admin password for ArgoCD."
}

variable "addon_config" {
  type        = any
  default     = {}
  description = "Configuration for managing add-ons via ArgoCD"
}

variable "addon_context" {
  type = object({
    aws_caller_identity_account_id = string
    aws_caller_identity_arn        = string
    aws_eks_cluster_endpoint       = string
    aws_partition_id               = string
    aws_region_name                = string
    eks_cluster_id                 = string
    eks_oidc_issuer_url            = string
    eks_oidc_provider_arn          = string
    tags                           = map(string)
  })
  description = "Input configuration for the addon"
}
