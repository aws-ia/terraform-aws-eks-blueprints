variable "eks_cluster_domain" {
  description = "Route53 domain for the cluster"
  type        = string
  default     = "example.com"
}

variable "certificate_name" {
  description = "name for the certificate"
  type        = string
  default     = "example"
}

variable "certificate_dns" {
  description = "CommonName used in the Certificate, usually DNS"
  type        = string
  default     = "example.com"
}
