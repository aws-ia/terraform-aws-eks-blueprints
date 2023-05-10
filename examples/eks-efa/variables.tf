variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "eks-efa"
}

variable "cluster_enabled_log_types" {
  description = "EKS Cluster Control Plane Logging"
  type        = list(any)
  default     = ["api", "authenticator", "audit", "scheduler", "controllerManager"]
}
