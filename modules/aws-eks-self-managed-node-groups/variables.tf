variable "self_managed_ng" {
  description = "Map of maps of `eks_self_managed_node_groups` to create"
  type        = any
  default     = {}
}

variable "vpc_id" {
  description = "VPC Id used in security group creation"
  type        = string
}

variable "private_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  default     = []
}

variable "public_subnet_ids" {
  description = "list of public subnets Id's for the Worker nodes"
  default     = []
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version of the cluster"
}

variable "eks_cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS Cluster K8s API server endpoint"
  type        = string
}

variable "cluster_ca_base64" {
  description = "Base64-encoded EKS cluster certificate-authority-data"
  type        = string
}

variable "cluster_primary_security_group_id" {
  description = "EKS Cluster primary security group ID"
  type        = string
  default     = ""
}

variable "cluster_security_group_id" {
  type        = string
  description = "EKS Cluster Security group ID for self managed node group"
  default     = ""
}

variable "worker_security_group_id" {
  description = "Worker group security ID"
  type        = string
  default     = ""
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
