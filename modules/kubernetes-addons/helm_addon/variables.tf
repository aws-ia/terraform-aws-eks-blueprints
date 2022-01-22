variable "name" {
  type        = string
  description = "Add-on name, this must be provided"
}

variable "helm_config" {
  type        = any
  description = "Add-on helm chart config, provide repository and version at the minimum"
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster name"
}

variable "tags" {
  type        = map(string)
  description = "Common tags for AWS resources"
}

variable "irsa_policies" {
  type        = list(string)
  default     = []
  description = "List IAM policy ARNs to be used for add-on IRSA"
}
