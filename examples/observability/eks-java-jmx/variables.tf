variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "adot001"
}

variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = "dev"
}

variable "grafana_endpoint" {
  default = "Grafana endpoint"
  type    = string
}

variable "grafana_api_key" {
  description = "Api key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  sensitive   = true
}
