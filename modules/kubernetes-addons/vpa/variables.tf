variable "helm_config" {
  type        = any
  description = "Helm provider config for VPA"
  default     = {}
}

variable "eks_cluster_id" {
  type        = string
  description = "EKS Cluster Id"
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps"
}
