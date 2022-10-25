variable "kyverno_helm_config" {
  description = "Helm provider config for the Kyverno"
  type        = any
  default     = {}
}

variable "kyverno_policies_helm_config" {
  description = "Helm provider config for the Kyverno baseline policies"
  type        = any
  default     = {}
}

variable "kyverno_policy_reporter_helm_config" {
  description = "Helm provider config for the Kyverno policy reporter UI"
  type        = any
  default     = {}
}

variable "enable_kyverno_policies" {
  description = "Enable Kyverno policies"
  type        = bool
  default     = false
}

variable "enable_kyverno_policy_reporter" {
  description = "Enable Kyverno UI"
  type        = bool
  default     = false
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
