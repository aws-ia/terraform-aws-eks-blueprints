variable "helm_config" {
  type        = any
  default     = {}
  description = "External DNS Helm Configuration"
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies used for the add-on service account."
}

variable "domain_name" {
  type        = string
  description = "Domain name of the Route53 hosted zone to use with External DNS."
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
