variable "helm_config" {
  type        = any
  description = "Helm provider config for the Karpenter"
  default     = {}
}

variable "irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies for a IAM role for service accounts"
  default     = []
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "node_iam_instance_profile" {
  description = "Karpenter Node IAM Instance profile id"
  default     = ""
  type        = string
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
