variable "argocd_domain" {
  description = "Hosted Zone domain"
  type        = string
  default     = "exmaple.com"
}

variable "argocd_domain_private_zone" {
  description = "Is ArgoCD private zone"
  type        = bool
  default     = false
}