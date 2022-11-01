variable "istio_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = "1.15.2"
}

variable "install_istio_base" {
  description = "Install Istio `base` Helm Chart"
  type        = bool
  default     = true
}

variable "install_istio_cni" {
  description = "Install Istio `cni` Helm Chart"
  type        = bool
  default     = true
}

variable "install_istiod" {
  description = "Install Istio `istiod` Helm Chart"
  type        = bool
  default     = true
}

variable "install_istio_ingressgateway" {
  description = "Install Istio `gateway` Helm Chart"
  type        = bool
  default     = true
}

variable "helm_config" {
  description = "Helm Config for Istio"
  type        = any
  default     = {}
}

variable "istio_base_settings" {
  description = "Additional settings which will be passed to the Helm chart values"
  type        = map(any)
  default     = {}
}

variable "istio_gateway_settings" {
  description = "Additional settings which will be passed to the Helm chart values"
  type        = map(any)
  default     = {}
}

variable "cleanup_on_fail" {
  description = "Allow deletion of new resources created in this upgrade when upgrade fails"
  type        = bool
  default     = true
}

variable "force_update" {
  description = "Force resource update through delete/recreate if needed"
  type        = bool
  default     = false
}

variable "istiod_global_network" {
  description = "Istio telementry network name"
  type        = string
  default     = "network1"
}

variable "istiod_global_meshID" {
  description = "Istio telementry mesh name"
  type        = string
  default     = "mesh1"
}

variable "istiod_meshConfig_accessLogFile" {
  description = "The mesh config access log file"
  default     = "/dev/stdout"
}

variable "istiod_meshConfig_rootNamespace" {
  description = "The mesh config root namespace"
  type        = string
  default     = "istio-system"
}

variable "istiod_meshConfig_enableAutoMtls" {
  description = "The mesh config enable AutoMtls"
  type        = bool
  default     = "true"
}

variable "istiod_meshConfig_trustDomain" {
  description = "The trust domain corresponds to the trust root of a system"
  type        = string
  default     = "td1"
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps."
  type        = bool
  default     = false
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
