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

variable "environment" {
  type = string
}

variable "tenant" {
  type = string
}

variable "zone" {
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_name" {
  description = "EKS Cluster name"
  type        = string
}
