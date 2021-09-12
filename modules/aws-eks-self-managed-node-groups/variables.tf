variable "self_managed_ng" {
  description = "Map of maps of `eks_self_managed_node_groups` to create"
  type        = any
  default     = {}
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "eks_cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_base64" {
  type = string
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes cluster version"
}

variable "default_worker_security_group_id" {
  type        = string
  default     = ""
  description = "Default worker security group id"
}

variable "cluster_primary_security_group_id" {
  type        = string
  default     = ""
  description = "Cluster Primary security group ID for self managed node group"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "path" {
  type        = string
  default     = "/"
  description = "IAM resource path, e.g. /dev/"
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
