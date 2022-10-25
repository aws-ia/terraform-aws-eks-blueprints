# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}

variable "region" {
  type        = string
  description = "The AWS Region"
  default     = "us-west-2"
}

variable "cluster_version" {
  type        = string
  description = "EKS K8s version 1.22"
  default     = "1.23"
}

variable "instance_types" {
  type        = list(string)
  description = "EC2 worker node instance types"
  default     = ["m5.large"]
}
