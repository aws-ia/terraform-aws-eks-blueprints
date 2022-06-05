variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC that will be created."
  type        = string
  default     = "10.0.0.0/16"
}
variable "default_vpc_ipv4_cidr" {
  description = "The CIDR block of the default VPC that hosts the bastion host or jenkins server."
  type        = string
  default     = null
}

