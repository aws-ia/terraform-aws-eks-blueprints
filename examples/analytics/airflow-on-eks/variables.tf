variable "name" {
  description = "Name of the VPC and EKS Cluster"
  default     = "airflow-on-eks"
  type        = string
}

variable "region" {
  description = "region"
  type        = string
  default     = "us-west-2"
}

variable "eks_cluster_version" {
  description = "EKS Cluster version"
  default     = "1.22"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
  type        = string
}
