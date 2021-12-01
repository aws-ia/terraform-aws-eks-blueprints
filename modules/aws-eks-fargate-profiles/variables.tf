
variable "fargate_profile" {
  description = "Map of maps of `eks_node_groups` to create"
  type        = any
  default     = {}
}

variable "eks_cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "path" {
  type        = string
  default     = "/"
  description = "IAM resource path, e.g. /dev/"
}
