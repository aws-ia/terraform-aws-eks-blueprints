# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}

variable "aws_access_key_id" {
  type        = string
  default     = ""
  description = "Access key to your AWS account"
}

variable "aws_secret_access_key" {
  type        = string
  default     = ""
  description = "Secret key to your AWS account"
}
