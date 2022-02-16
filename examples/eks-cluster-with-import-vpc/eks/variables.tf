variable "kubernetes_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.21"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "tf_state_vpc_s3_bucket" {
  type        = string
  description = "Terraform state S3 Bucket Name"
}

variable "tf_state_vpc_s3_key" {
  type        = string
  description = "Terraform state S3 Key path"
}

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
