variable "tenant" {
  type        = string
  description = "AWS account name or unique id for tenant"
}

variable "environment" {
  type        = string
  description = "Environment area eg., preprod or prod"
}

variable "zone" {
  type        = string
  description = "Environment with in one sub_tenant or business unit"
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "terraform_version" {
  type = string
}
