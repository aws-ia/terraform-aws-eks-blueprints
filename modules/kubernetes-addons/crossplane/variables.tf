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

variable "aws_provider" {
  description = "AWS Provider config for Crossplane"
  type = object({
    enable                   = bool
    provider_aws_version     = string
    additional_irsa_policies = list(string)
  })
}

variable "jet_aws_provider" {
  description = "AWS Provider Jet AWS config for Crossplane"
  type = object({
    enable                   = bool
    provider_aws_version     = string
    additional_irsa_policies = list(string)
  })
}

variable "account_id" {
  description = "Current AWS Account ID"
  type        = string
}

variable "aws_partition" {
  description = "AWS Identifier of the current partition e.g., aws or aws-cn"
  type        = string
}
