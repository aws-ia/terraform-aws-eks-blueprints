variable "addon_config" {
  description = "Amazon EKS Managed CoreDNS Add-on config"
  type        = any
  default     = {}
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

variable "helm_config" {
  description = "Helm provider config for the aws_efs_csi_driver"
  default     = {}
  type        = any
}

variable "use_managed_addon" {
  description = "Determines whether to use the EKS mangaed addon (default, `true`) or to provision as self-managed/custom addon using Helm chart (`false`)"
  type        = bool
  default     = true
}
