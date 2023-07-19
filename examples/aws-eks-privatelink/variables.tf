variable "endpoint_service_name" {
  description = "Name of the VPC endpoint service"
  type        = string
  default     = "k8s-api-server-eps"
}

variable "endpoint_name" {
  description = "Name of the VPC endpoint"
  type        = string
  default     = "k8s-api-server-ep"
}
