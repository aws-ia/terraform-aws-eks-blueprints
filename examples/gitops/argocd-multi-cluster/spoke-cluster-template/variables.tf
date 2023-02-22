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
variable "addons" {
  description = "Spoke Cluster Environment"
  type        = any
  default     = {}
}
# Multi-account Multi-region support
variable "spoke_region" {
  description = "Spoke Cluster Region"
  type        = string
  default     = "us-west-2"
}
variable "spoke_profile" {
  description = "Spoke Cluster CLI Profile"
  type        = string
  default     = "default"
}
variable "hub_region" {
  description = "Hub Cluster Region"
  type        = string
  default     = "us-west-2"
}
variable "hub_profile" {
  description = "Hub Cluster CLI Profile"
  type        = string
  default     = "default"
}
