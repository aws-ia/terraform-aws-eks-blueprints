
variable "eks_cluster_id" {
  type        = string
  description = "EKS Cluster ID"
}

variable "amazon_prometheus_workspace_alias" {
  type        = string
  default     = null
  description = "AWS Managed Prometheus WorkSpace Name"
}

variable "namespace" {
  type        = string
  default     = "prometheus"
  description = "Prometheus Server Namespace"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "iam_role_path" {
  type        = string
  default     = "/"
  description = "IAM role path"
}
