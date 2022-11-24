variable "chart_repository" {
  type        = string
  description = "The argocd-application helm-chart repository URL  "
  default     = ""
}
variable "chart_version" {
  type        = string
  description = "The helm-chart version"
  default     = ""
}
