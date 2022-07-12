variable "grafana_endpoint" {
  description = "Grafana endpoint"
  type        = string
  default     = null
}

variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-west-2"
}
