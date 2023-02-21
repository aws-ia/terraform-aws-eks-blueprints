variable "helm_config" {
  description = "ArgoCD Helm Chart Config values"
  type        = any
  default     = {}
}

variable "applications" {
  description = "ArgoCD Application config used to bootstrap a cluster."
  type        = any
  default     = {}
}

variable "addon_config" {
  description = "Configuration for managing add-ons via ArgoCD"
  type        = any
  default     = {}
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
  default     = {}
}

variable "argocd_remote" {
  description = "Setup Remote Cluster"
  type        = bool
  default     = false
}
