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

variable "crossplane_provider_aws" {
  description = "AWS Provider config for Crossplane"
  type = object({
    provider_aws_version     = string
    additional_irsa_policies = list(string)
  })
}

variable "context" {
  type = object({
    aws_partition = any
    aws_caller_identity    = any
    aws_eks_cluster = any
  })
  description = "Input configuration for IRSA module"
}