variable "eks_cluster_domain" {
  type        = string
  description = "Route53 domain for the cluster."
}

variable "acm_certificate_domain" {
  type        = string
  description = "ACM Certificate domain for the cluster."
}
