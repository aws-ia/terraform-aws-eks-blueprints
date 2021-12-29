variable "eks_cluster_id" {
  type = string
}

variable "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer."
  default     = ""
}

variable "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider."
  default     = ""
}

variable "common_tags" {
  type = map(string)
}

variable "add_on_config" {
  description = "Amazon EKS Managed Add-on config for EBS CSI Driver"
  type        = any
  default     = {}
}

variable "iam_role_path" {
  type        = string
  default     = "/"
  description = "IAM role path"
}
