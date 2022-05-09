variable "region" {
  type        = string
  description = "AWS region"
}
variable "eks_cluster_id" {
  description = "EKS Cluster ID/name"
  type        = string
}

variable "eks_cluster_domain" {
  type        = string
  description = "Route53 domain for the cluster."
  default     = "example.com"
}

variable "acm_certificate_domain" {
  type        = string
  description = "*.example.com"
}
