variable "helm_config" {
  type        = any
  description = <<EOT
Add-on helm chart config, provide repository and version at the minimum.
See https://registry.terraform.io/providers/hashicorp/helm/latest/docs.
EOT
}

variable "set_values" {
  type        = any
  description = "Forced set values"
  default     = []
}

variable "set_sensitive_values" {
  type        = any
  description = "Forced set_sensitive values"
  default     = []
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "irsa_config" {
  type = object({
    kubernetes_namespace              = string
    create_kubernetes_namespace       = bool
    kubernetes_service_account        = string
    create_kubernetes_service_account = bool
    eks_cluster_id                    = string
    iam_role_path                     = string
    tags                              = map(string)
    irsa_iam_policies                 = list(string)
    irsa_iam_permissions_boundary     = string
  })
  description = "Input configuration for IRSA module"
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
