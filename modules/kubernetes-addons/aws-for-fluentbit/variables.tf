variable "helm_config" {
  type        = any
  description = "Helm provider config aws_for_fluent_bit."
  default     = {}
}

variable "cw_log_group_name" {
  type        = string
  description = "FluentBit CloudWatch Log group name"
  default     = null
}

variable "cw_log_group_retention" {
  type        = number
  description = "FluentBit CloudWatch Log group retention period"
  default     = 90
}

variable "cw_log_group_kms_key_arn" {
  type        = string
  description = "FluentBit CloudWatch Log group KMS Key"
  default     = null
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies for a IAM role for service accounts"
  default     = []
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
    irsa_iam_role_path             = string
    irsa_iam_permissions_boundary  = string
  })
  description = "Input configuration for the addon"
}
