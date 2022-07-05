variable "helm_config" {
  description = "Helm provider config for the Kubernetes Dashboard"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps"
  type        = bool
  default     = false
}

variable "addon_context" {
  description = "Input configuration for the addon"
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
}

variable "use_kubernetes_provider" {
  description = "Use kubernetes provider"
  type        = bool
  default     = true
}

variable "use_kubectl_provider" {
  description = "Use kubectl provider"
  type        = bool
  default     = false
}
