variable "addon_config" {
  description = "Amazon EKS Managed Add-on config for EBS CSI Driver"
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
    irsa_iam_role_path             = string
    irsa_iam_permissions_boundary  = string
  })
}

variable "enable_amazon_eks_aws_ebs_csi_driver" {
  description = "Enable EKS Managed AWS EBS CSI Driver add-on"
  type        = bool
  default     = false
}

variable "enable_self_managed_aws_ebs_csi_driver" {
  description = "Enable self-managed aws-ebs-csi-driver add-on"
  type        = bool
  default     = false
}

variable "helm_config" {
  description = "Self-managed aws-ebs-csi-driver Helm chart config"
  type        = any
  default     = {}
}
