variable "opensearch_dashboard_user" {
  description = "OpenSearch dashboard user"
  type        = string
}

variable "opensearch_dashboard_pw" {
  description = "OpenSearch dashboard user password"
  type        = string
}

variable "name" {
  type        = string
  description = "cluster name"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_cidr" {
  description = "The CIDR block of the default VPC that hosts the EKS cluster."
  type        = string
}