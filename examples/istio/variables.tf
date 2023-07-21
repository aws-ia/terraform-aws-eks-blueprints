# For Istio
variable "istio_helm_chart_version" {
  type        = string
  default     = "1.18.1"
  description = "Istio Helm chart version."
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "eks_cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.27"
}

variable "min_size" {
  description = "Minimum size of Managed Nodegroup"
  type = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of Managed Nodegroup"
  type        = number
  default     = 1
}

variable "desired_size" {
  description = "Desired size of Managed Nodegroup"
  type    = number
  default     = 1
}

