variable "eks_cluster_id" {
  type        = string
  description = "EKS Cluster ID"
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}


variable "add_on_config" {
  description = "Amazon EKS Managed CoreDNS Add-on config"
  type        = any
  default     = {}
}

variable "iam_role_path" {
  type        = string
  default     = "/"
  description = "IAM role path"
}
