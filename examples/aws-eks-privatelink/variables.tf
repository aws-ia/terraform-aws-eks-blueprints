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

variable "handle_eni_cleanup_lambda_freq" {
  description = "Frequency in mins, how often the clean up lambda needs to run"
  type        = number
  default     = 15
}
