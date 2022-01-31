variable "helm_config" {
  type        = any
  description = "Helm provider config for the Karpenter"
  default     = {}
}

variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster Id"
}

variable "irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies for a IAM role for service accounts"
  default     = []
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "tags" {
  type        = map(string)
  description = "Common Tags for AWS resources"
}

variable "node_iam_instance_profile" {
  description = "Karpenter Node IAM Instance profile id"
  default     = ""
  type        = string
}
