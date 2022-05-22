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

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
}

variable "environment" {
  type        = string
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
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

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}
