variable "fargate_profile" {
  description = "Map of maps of `eks_node_groups` to create"
  type        = any
  default     = {}
}

variable "path" {
  type        = string
  default     = "/"
  description = "IAM resource path, e.g. /dev/"
}

variable "context" {
  type = object({
    eks_cluster_id   = string
    aws_partition_id = string
    tags             = map(string)
  })
  description = "Input configuration for Fargate"
}
