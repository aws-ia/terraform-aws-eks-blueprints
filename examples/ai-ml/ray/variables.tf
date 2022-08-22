variable "eks_cluster_domain" {
  description = "Optional Route53 domain for the cluster."
  type        = string
  default     = null
}

variable "acm_certificate_domain" {
  description = "Optional Route53 certificate domain"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}
