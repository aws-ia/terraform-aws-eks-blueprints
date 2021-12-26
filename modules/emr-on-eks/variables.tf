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

variable "eks_cluster_id" {
  type = string
  description = "EKS Cluster ID"
}

variable "tags" {
  type        = map(string)
  description = "Common Tags for AWS resources"
}

variable "emr_on_eks_teams" {
  description = "EMR on EKS Teams configuration"
  type        = any
  default     = {}
}

variable "iam_role_path" {
  type        = string
  default     = "/"
  description = "IAM role path"
}
