variable "eks_cluster_domain" {
  type        = string
  description = "Optional Route53 domain for the cluster."
  default     = null
}

variable "acm_certificate_domain" {
  type        = string
  description = "Optional Route53 certificate domain"
  default     = null
}
