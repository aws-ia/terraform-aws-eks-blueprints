variable "grafana_endpoint" {
  description = "Grafana endpoint"
  type        = string
  default     = "https://example.com"
}

variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = ""
  sensitive   = true
}
