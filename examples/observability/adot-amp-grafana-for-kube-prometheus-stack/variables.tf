variable "grafana_endpoint" {
  description = "Grafana endpoint"
  type        = string
  default     = "https://g-f68db83172.grafana-workspace.us-east-1.amazonaws.com"
}

variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = "eyJrIjoic0dTMEJtQzNhR2RKQ2lBdVpRYlNLMmYxY2h2RGYxYWUiLCJuIjoiZGVzdHJvdSIsImlkIjoxfQ=="
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region"
  type       = string
  default    = "us-east-1"
}
