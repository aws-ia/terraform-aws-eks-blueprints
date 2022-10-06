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

variable "enable_amazon_eks_coredns" {
  description = "Enable Amazon EKS CoreDNS add-on"
  type        = bool
  default     = false
}

variable "addon_config" {
  description = "Amazon EKS Managed CoreDNS Add-on config"
  type        = any
  default     = {}
}

variable "enable_self_managed_coredns" {
  description = "Enable self-managed CoreDNS add-on"
  type        = bool
  default     = false
}

variable "helm_config" {
  description = "Helm provider config for the aws_efs_csi_driver"
  default     = {}
  type        = any
}

variable "remove_default_coredns_deployment" {
  description = "Determines whether the default deployment of CoreDNS is removed and ownership of kube-dns passed to Helm"
  type        = bool
  default     = false
}

variable "eks_cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with your cluster"
  type        = string
  default     = ""
}

variable "enable_cluster_proportional_autoscaler" {
  description = "Enable cluster-proportional-autoscaler"
  type        = bool
  default     = true
}

variable "cluster_proportional_autoscaler_helm_config" {
  description = "Helm provider config for the CoreDNS cluster-proportional-autoscaler"
  default     = {}
  type        = any
}
