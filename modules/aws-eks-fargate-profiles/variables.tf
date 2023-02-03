variable "fargate_profile" {
  description = "Map of maps of `eks_node_groups` to create"
  type        = any
  default     = {}
}

variable "context" {
  description = "Input configuration for Fargate"
  type = object({
    eks_cluster_id                = string
    aws_partition_id              = string
    iam_role_path                 = string
    iam_role_permissions_boundary = string
    tags                          = map(string)
  })
}
