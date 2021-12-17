variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "aws"
}

variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = "test"
}

# VPC Config for EKS Cluster
variable "vpc_id" {
  type        = string
  description = "VPC id"
  default     = ""
}

variable "private_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "list of public subnets Id's for the Worker nodes"
  type        = list(string)
  default     = []
}
