variable "helm_config" {
  description = "Helm provider config for the Karpenter"
  type        = any
  default     = {}
}

variable "irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps."
  type        = bool
  default     = false
}

variable "node_iam_instance_profile" {
  description = "Karpenter Node IAM Instance profile id"
  type        = string
  default     = ""
}

variable "enable_spot_termination" {
  description = "Determines whether to enable native spot termination handling"
  type        = bool
  default     = false
}

variable "addon_context" {
  description = "Input configuration for the addon"
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
    irsa_iam_role_path             = string
    irsa_iam_permissions_boundary  = string
  })
}

variable "path" {
  description = "Path in which to create the Karpenter policy"
  type        = string
  default     = "/"
}

variable "sqs_queue_managed_sse_enabled" {
  description = "Enable server-side encryption (SSE) for a SQS queue"
  type        = bool
  default     = true
}

variable "sqs_queue_kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK"
  type        = string
  default     = null
}

variable "sqs_queue_kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again"
  type        = number
  default     = null
}

variable "rule_name_prefix" {
  description = "Prefix used for all event bridge rules"
  type        = string
  default     = ""

  validation {
    condition     = length(var.rule_name_prefix) <= 14
    error_message = "Maximum input length exceeded. Please enter no more than 14 characters."
  }
}
