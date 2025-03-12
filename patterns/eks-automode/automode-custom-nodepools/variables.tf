variable "name" {
  description = "Name of the VPC and EKS Cluster"
  type        = string
  default     = "automode-custom"
}
variable "region" {
  description = "Region"
  default     = "us-east-1"
  type        = string
}
variable "eks_cluster_version" {
  description = "EKS Cluster version"
  type        = string
  default     = "1.31"
}
variable "tags" {
  description = "Default tags"
  type        = map(string)
  default     = {}
}

# VPC with ~250 IPs (10.1.0.0/24) and 2 AZs
variable "vpc_cidr" {
  description = "VPC CIDR. This should be a valid private (RFC 1918) CIDR range"
  type        = string
  default     = "10.1.0.0/24"
}

# Cloudwatch Observability addon sends logs and metrics to CloudWatch
variable "enable_cloudwatch_observability" {
  description = "Deploy Cloudwatch Observability addon to enable managed observability in the cluster"
  type        = bool
  default     = false
}
