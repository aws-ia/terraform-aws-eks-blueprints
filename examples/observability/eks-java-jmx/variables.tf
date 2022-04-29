variable "grafana_endpoint" {
  default = "Grafana endpoint"
  type    = string
}

variable "grafana_api_key" {
  description = "Api key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  sensitive   = true
}
