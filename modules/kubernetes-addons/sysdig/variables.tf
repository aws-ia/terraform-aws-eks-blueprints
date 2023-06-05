#Helm config
variable "helm_config" {
  type        = any
  description = "Helm Configuration for Sysdig Agent"
  default     = {}
}

# Manage via gitops
variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps"
  type        = bool
  default     = false
}

# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Cluster name"
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
    tags                           = map(string)
  })
}
