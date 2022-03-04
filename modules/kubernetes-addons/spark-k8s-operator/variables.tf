variable "helm_config" {
  type        = any
  description = "Helm provider config for Spark K8s Operator"
  default     = {}
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps"
}

variable "spark_irsa_policies" {
  type        = list(string)
  default     = []
  description = "IAM Policy ARN list for any IRSA policies for Spark App"
}

variable "spark_irsa_permissions_boundary" {
  type        = string
  default     = ""
  description = "IAM Policy ARN for IRSA IAM role permissions boundary for Spark App"
}

variable "spark_operator_irsa_policies" {
  type        = list(string)
  default     = []
  description = "IAM Policy ARN list for any IRSA policies for Spark Operator"
}

variable "spark_operator_irsa_permissions_boundary" {
  type        = string
  default     = ""
  description = "IAM Policy ARN for IRSA IAM role permissions boundary Spark Operator"
}

variable "addon_context" {
  type = object({
    aws_caller_identity_account_id = string
    aws_caller_identity_arn        = string
    aws_eks_cluster_endpoint       = string
    aws_partition_id               = string
    aws_region_name                = string
    eks_cluster_id                 = string
    eks_oidc_issuer_url            = string
    eks_oidc_provider_arn          = string
    tags                           = map(string)
  })
  description = "Input configuration for the addon"
}