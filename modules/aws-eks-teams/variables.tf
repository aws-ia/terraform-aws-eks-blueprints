variable "eks_cluster_id" {
  description = "EKS Cluster name"
  type        = string
}

variable "application_teams" {
  description = "Map of maps of application teams to create"
  type        = any
  default     = {}
}

variable "platform_teams" {
  description = "Map of maps of platform teams to create"
  type        = any
  default     = {}
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "application_team_iam_policy" {
  description = "IAM policy for application team IAM role"
  type        = string
  default     = ""
}

variable "platform_team_iam_policy" {
  description = "IAM policy for platform team IAM role"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
