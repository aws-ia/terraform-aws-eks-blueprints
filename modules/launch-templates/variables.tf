variable "launch_template_config" {
  type = map(object({
    ami                = string
    launch_template_os = optional(string)
    launch_template_id = string
    block_device_mappings = list(object({
      device_name           = string
      volume_type           = string
      volume_size           = string
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      kms_key_id            = optional(string)
      iops                  = optional(number)
      throughput            = optional(number)
    }))
    pre_userdata         = optional(string)
    bootstrap_extra_args = optional(string)
    post_userdata        = optional(string)
    kubelet_extra_args   = optional(string)
  }))
}

variable "worker_security_group_id" {
  description = "Worker group security ID"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile for Launch Templates"
  type        = string
}

variable "eks_cluster_id" {
  description = "EKS Cluster name"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "http_endpoint" {
  type        = string
  default     = "enabled"
  description = "Whether the Instance Metadata Service (IMDS) is available. Supported values: enabled, disabled"
}

variable "http_tokens" {
  type        = string
  default     = "optional"
  description = "If enabled, will use Instance Metadata Service Version 2 (IMDSv2). Supported values: optional, required."
}

variable "http_put_response_hop_limit" {
  type        = number
  default     = 1
  description = "HTTP PUT response hop limit for instance metadata requests. Supported values: 1-64."
}
