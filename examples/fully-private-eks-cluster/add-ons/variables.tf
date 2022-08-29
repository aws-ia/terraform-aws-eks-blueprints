variable "region" {
  type        = string
  description = "AWS region"
}
variable "eks_cluster_id" {
  description = "EKS Cluster ID/name"
  type        = string
}
variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.23`)"
  type        = string
  default     = "1.23"
}
