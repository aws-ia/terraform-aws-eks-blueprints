variable "name" {
  type        = string
  description = "cluster name"
  default     = "aws013-preprod-test-eks"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "The CIDR block of the default VPC that hosts the EKS cluster."
  type        = string
  default     = "10.0.0.0/16"
}