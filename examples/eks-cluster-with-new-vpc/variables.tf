# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "Target region to deploy in"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}

