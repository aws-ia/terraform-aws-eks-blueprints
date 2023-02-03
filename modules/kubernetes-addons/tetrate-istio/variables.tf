variable "distribution" {
  description = "Istio distribution"
  type        = string
  default     = "TID"
}

variable "distribution_version" {
  description = "Istio version"
  type        = string
  default     = ""
}

variable "install_base" {
  description = "Install Istio `base` Helm Chart"
  type        = bool
  default     = true
}

variable "install_cni" {
  description = "Install Istio `cni` Helm Chart"
  type        = bool
  default     = true
}

variable "install_istiod" {
  description = "Install Istio `istiod` Helm Chart"
  type        = bool
  default     = true
}

variable "install_gateway" {
  description = "Install Istio `gateway` Helm Chart"
  type        = bool
  default     = true
}

variable "base_helm_config" {
  description = "Istio `base` Helm Chart Configuration"
  type        = any
  default     = {}
}

variable "cni_helm_config" {
  description = "Istio `cni` Helm Chart Configuration"
  type        = any
  default     = {}
}

variable "istiod_helm_config" {
  description = "Istio `istiod` Helm Chart Configuration"
  type        = any
  default     = {}
}

variable "gateway_helm_config" {
  description = "Istio `gateway` Helm Chart Configuration"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps"
  type        = bool
  default     = false
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
}
