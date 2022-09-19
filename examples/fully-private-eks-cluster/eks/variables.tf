variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.23`)"
  type        = string
  default     = "1.23"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

#-------------------------------
# EKS Cluster Security Groups
#-------------------------------
variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster will be deployed to"
}

variable "private_subnet_ids" {
  description = "List of the private subnet IDs"
  type        = list(string)
  default     = []
}
