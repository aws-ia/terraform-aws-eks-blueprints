variable "eks_cluster_id" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "add_on_config" {
  description = "Amazon EKS Managed Add-on"
  type        = any
  default     = {}
}

variable "iam_role_path" {
  type        = string
  default     = "/"
  description = "IAM role path"
}
