variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}

variable "eks_cluster_domain" {
  description = "Optional Route53 domain for the cluster."
  type        = string
  default     = ""
}
