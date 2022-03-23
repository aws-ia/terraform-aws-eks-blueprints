variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}

variable "managed_node_groups" {
  type        = any
  description = "A map of Managed node group(s)"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "aws"
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = "dev"
}
