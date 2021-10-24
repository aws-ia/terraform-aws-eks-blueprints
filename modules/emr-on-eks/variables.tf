
variable "environment" {
  type = string
}

variable "tenant" {
  type = string
}

variable "zone" {
  type = string
}

variable "eks_cluster_id" {
  type = string
}

variable "emr_on_eks_teams" {
  description = "EMR on EKS Teams configuration"
  type        = any
  default     = {}
}
