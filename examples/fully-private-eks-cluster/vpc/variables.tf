variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "eks_vpc_cidr" {
  description = "The CIDR block for the VPC that will be created."
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_vpc_name" {
  description = "The name of the VPC that will host the EKS cluster."
  type        = string
  default     = "eks_vpc"
}

variable "cloud9_vpc_cidr" {
  description = "The CIDR block for the VPC that will be created."
  type        = string
  default     = "172.31.0.0/16"
}

variable "cloud9_vpc_name" {
  description = "The name of the VPC that will host the Cloud9 instance."
  type        = string
  default     = "cloud9_vpc"
}

variable "cloud9_owner_arn" {
  description = "The arn of the IAM user who would be the owner of the Cloud9 instance."
  type        = string
  default     = ""
}
