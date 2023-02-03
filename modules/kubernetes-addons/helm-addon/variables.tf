variable "helm_config" {
  description = "Helm chart config. Repository and version required. See https://registry.terraform.io/providers/hashicorp/helm/latest/docs"
  type        = any
}

variable "set_values" {
  description = "Forced set values"
  type        = any
  default     = []
}

variable "set_sensitive_values" {
  description = "Forced set_sensitive values"
  type        = any
  default     = []
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps"
  type        = bool
  default     = false
}

variable "irsa_iam_role_name" {
  description = "IAM role name for IRSA"
  type        = string
  default     = ""
}

variable "irsa_config" {
  description = "Input configuration for IRSA module"
  type        = any
  default     = {}
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
}
