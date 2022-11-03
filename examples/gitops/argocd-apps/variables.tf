variable "chart_repository" {
  description = "Argocd-apps chart repository"
  type        = string
  default     = ""
}

variable "chart_version"{
  description = "Argocd-apps chart version"
  type        = string
  default     = ""
}
variable "github_repository_url"{
  description = "Argocd-apps repository url"
  type        = string
  default     = ""
}
variable "github_directory_path" {
  description = "Directory for application manifests"
  type        = string
  default     = ""
}
