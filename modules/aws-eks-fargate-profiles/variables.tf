
variable "enable_fargate" {
  description = "Enable Fargate profiles"
  type        = bool
  default     = false
}

variable "eks_cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "private_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  type        = list(string)
  default     = []
}

variable "fargate_profile" {
  description = "Map of maps of `eks_node_groups` to create"
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
