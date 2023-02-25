variable "hub_cluster_name" {
  description = "Hub Cluster Name"
  type        = string
  default     = "hub-cluster"
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
variable "argocd_domain" {
  description = "Hosted Zone domain"
  type        = string
  default     = "exmaple.com"
}
variable "argocd_domain_private_zone" {
  description = "Is ArgoCD private zone"
  type        = bool
  default     = false
}
