variable "helm_config" {
  description = "Helm provider config for velero"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps"
  type        = bool
  default     = false
}

variable "irsa_policies" {
  description = "Additional IAM policy ARNs for Velero IRSA"
  type        = list(string)
  default     = []
}

variable "backup_s3_bucket" {
  description = "Bucket name for velero bucket"
  type        = string
  default     = ""
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
    irsa_iam_role_path             = string
    irsa_iam_permissions_boundary  = string
    tags                           = map(string)
  })
}
