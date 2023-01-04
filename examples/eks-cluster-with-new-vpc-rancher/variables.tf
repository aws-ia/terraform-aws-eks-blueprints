# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}

variable "eks_cluster_domain" {
  default = ""
}

variable "install_letsencrypt_issuers" {
  default =  "true"
}

variable "letsencrypt_email" {
  default = ""
}