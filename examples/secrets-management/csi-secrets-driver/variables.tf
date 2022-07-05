variable "use_kubernetes_provider" {
  description = "Use kubernetes provider"
  type        = bool
  default     = true
}

variable "use_kubectl_provider" {
  description = "Use kubectl provider"
  type        = bool
  default     = false
}
