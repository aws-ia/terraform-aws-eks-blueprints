variable "eks_cluster_id" {
  type        = string
  description = "EKS Cluster ID"
}

variable "amazon_prometheus_workspace_alias" {
  type        = string
  default     = null
  description = "AWS Managed Prometheus WorkSpace Name"
}

variable "amazon_prometheus_rule_group_data" {
  type        = string
  default     = null
  description = "Manages an Amazon Managed Service for Prometheus (AMP) Rule Group Namespace"
}

variable "amazon_prometheus_alert_manager_definition" {
  type        = string
  default     = null
  description = "Manages an Amazon Managed Service for Prometheus (AMP) Alert Manager Definition"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the object."
}
