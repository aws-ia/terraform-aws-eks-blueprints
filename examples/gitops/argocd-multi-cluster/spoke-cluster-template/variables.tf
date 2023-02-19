variable "hub_cluster_name" {
  description = "Hub Cluster Name"
  type        = string
  default     = "hub-cluster"
}
variable "spoke_cluster_name" {
  description = "Spoke Cluster Name"
  type        = string
  default     = "cluster-n"
}
variable "environment" {
  description = "Spoke Cluster Environment"
  type        = string
  default     = "dev"
}