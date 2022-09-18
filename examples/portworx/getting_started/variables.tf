# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}

variable "aws_access_key_id" {
  description = "Access key to a new IAM user with required policy attached"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "Secret key to a new IAM user with required policy attached"
  type        = string
  default     = ""
  sensitive   = true
}
