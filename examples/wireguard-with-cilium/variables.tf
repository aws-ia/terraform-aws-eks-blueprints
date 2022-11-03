# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}

variable "enable_example" {
  description = "Enable example to test this blueprint"
  type        = bool
  default     = true
}