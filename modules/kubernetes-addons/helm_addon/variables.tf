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
  type        = map(any)
  description = "Input configuration for IRSA module"
  default     = null
}
