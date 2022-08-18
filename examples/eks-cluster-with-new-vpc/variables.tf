# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}

variable "region" {
  description = "The name of the AWS region - used by Terratest for e2e test automation"
  type        = string
  default     = "us-west-2"
}
