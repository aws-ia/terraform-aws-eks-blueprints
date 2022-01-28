variable "helm_config" {
  type        = any
  description = "Add-on helm chart config, provide repository and version at the minimum"
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "irsa_config" {
  type        = map(any)
  description = "Input configuration for IRSA module"
  default     = null
}
