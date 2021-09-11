variable "self_managed_ng" {
  description = "Map of maps of `eks_self_managed_node_groups` to create"
  type        = any
  default     = {}
}

variable "vpc_id" {
  type = string
}

variable "self_managed_public_subnet_ids" {
  type = list(string)
}

variable "self_managed_private_subnet_ids" {
  type = list(string)
}

variable "cluster_full_name" {
  type = string
}

variable "cluster_security_group" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca" {
  type = string
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes cluster version"
}

variable "custom_security_group_id" {
  type        = string
  default     = ""
  description = "Custom security group ID for self managed node group"
}

variable "cluster_autoscaler_enable" {
  type        = bool
  description = "Enable Cluster Autoscaler"
  default     = false
}

variable "common_tags" {
  type = map(string)
}