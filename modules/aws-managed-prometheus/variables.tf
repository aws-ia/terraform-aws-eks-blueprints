variable "eks_cluster_id" {
  description = "EKS Cluster ID"
  type        = string
}

variable "amazon_prometheus_workspace_alias" {
  description = "AWS Managed Prometheus WorkSpace Name"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the object"
  type        = map(string)
}
