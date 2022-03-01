variable "helm_config" {
  type        = any
  description = "Helm provider config for the Argo Rollouts"
  default     = {}
}

variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster Id"
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "tags" {
  type        = map(string)
  description = "Common Tags for AWS resources"
  default     = {}
}

variable "irsa_iam_permissions_boundary" {
  type        = string
  default     = ""
  description = "IAM Policy ARN for IRSA IAM role permissions boundary"
}

variable "context" {
  type = object({
    aws_partition       = any
    aws_caller_identity = any
    aws_eks_cluster     = any
    aws_region          = any
  })
  description = "Input configuration for IRSA module"
}
