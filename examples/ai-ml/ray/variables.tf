variable "eks_cluster_domain" {
  default     = null
  description = "Optional Route53 domain for the cluster."
  type        = string
}

variable "acm_certificate_domain" {
  default     = null
  description = "Optional Route53 certificate domain"
  type        = string
}

variable "region" {
  default     = "us-west-2"
  description = "AWS Region"
  type        = string
}
