variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "EKS Cluster Name and the VPC name"
  type        = string
  default     = ""
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.28"
}

variable "capacity_type" {
  type        = string
  description = "Capacity SPOT or ON_DEMAND"
  default     = "SPOT"
}

variable "kubecost_token" {
  type        = string
  description = "To find or obtain Kubecost token, go to https://www.kubecost.com/install#show-instructions"
}
