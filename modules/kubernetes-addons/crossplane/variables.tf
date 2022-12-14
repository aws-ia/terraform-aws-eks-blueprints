variable "helm_config" {
  description = "Helm provider config for the Argo Rollouts"
  type        = any
  default     = {}
}

variable "aws_provider" {
  description = "AWS Provider config for Crossplane"
  type = object({
    enable                   = bool
    provider_aws_version     = string
    additional_irsa_policies = list(string)
  })
  default = {
    enable = true
    provider_aws_version = "v0.33.0"
    additional_irsa_policies = []
  }
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
    irsa_iam_role_path             = string
    irsa_iam_permissions_boundary  = string
  })
}

variable "jet_aws_provider" {
  description = "AWS Provider Jet AWS config for Crossplane"
  type = object({
    enable                   = bool
    provider_aws_version     = string
    additional_irsa_policies = list(string)
  })
  default = {
    enable = true
    provider_aws_version = "v0.4.1"
    additional_irsa_policies = []
  }
}

variable "kubernetes_provider" {
  description = "Kubernetes Provider config for Crossplane"
  type = object({
    enable                      = bool
    provider_kubernetes_version = string
  })
  default = {
    enable = true
    provider_kubernetes_version = "v0.5.0"
  }
}

variable "helm_provider" {
  description = "Helm Provider config for Crossplane"
  type = object({
    enable                = bool
    provider_helm_version = string
  })
  default = {
    enable = true
    provider_helm_version = "v0.12.0"
  }
}

variable "terraform_provider" {
  description = "Terraform Provider config for Crossplane"
  type = object({
    enable                     = bool
    provider_terraform_version = string
    additional_irsa_policies   = list(string)
  })
  default = {
    enable = false
    provider_terraform_version = "v0.5.0"
    additional_irsa_policies = []
  }
}

variable "account_id" {
  description = "Current AWS Account ID"
  type        = string
}

variable "aws_partition" {
  description = "AWS Identifier of the current partition e.g., aws or aws-cn"
  type        = string
}
