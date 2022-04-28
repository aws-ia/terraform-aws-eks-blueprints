variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.21"
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "tf001"
}

variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = "dev"
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

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}
