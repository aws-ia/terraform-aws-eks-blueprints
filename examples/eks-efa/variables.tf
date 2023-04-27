variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "core_stack_name" {
  description = "The name of Core Infrastructure stack, feel free to rename it. Used for cluster and VPC names."
  type        = string
  default     = "eks-efa"
}

variable "hosted_zone_name" {
  type        = string
  description = "Route53 domain for the cluster."
  default     = ""
}

variable "eks_admin_role_name" {
  type        = string
  description = "Additional IAM role to be admin in the cluster"
  default     = ""
}

variable "vpc_tag_key" {
  description = "The tag key of the VPC and subnets"
  type        = string
  default     = "Name"
}

variable "vpc_tag_value" {
  # if left blank then {core_stack_name} will be used
  description = "The tag value of the VPC and subnets"
  type        = string
  default     = ""
}
