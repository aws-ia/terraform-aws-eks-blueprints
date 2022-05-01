variable "application_teams" {
  description = "Map of maps of teams to create"
  type        = any
  default     = {}
}

variable "platform_teams" {
  description = "Map of maps of teams to create"
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_id" {
  description = "EKS Cluster name"
  type        = string
}
