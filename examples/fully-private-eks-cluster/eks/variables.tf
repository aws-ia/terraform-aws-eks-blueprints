variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster will be deployed to"
}

variable "private_subnet_ids" {
  description = "List of the private subnet IDs"
  type        = list(string)
  default     = []
}
