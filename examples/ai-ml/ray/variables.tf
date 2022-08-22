variable "eks_cluster_domain" {
  default     = null
  type        = string
  description = "Optional Route53 domain for the cluster."
}

variable "acm_certificate_domain" {
  default     = null
  type        = string
  description = "Optional Route53 certificate domain"
}

variable "region" {
  default     = "us-west-2"
  type        = string
  description = "AWS Region"
}
