variable "helm_config" {
  description = "Helm chart config. Repository and version required. See https://registry.terraform.io/providers/hashicorp/helm/latest/docs"
  type        = any
  default     = {}
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
  default     = {}
}
