variable "grafana_endpoint" {
  type = string
}

variable "grafana_api_key" {
  type        = string
  sensitive   = true
  description = "Api key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
}

variable "opensearch_dashboard_user" {
  type = string
}

variable "opensearch_dashboard_pw" {
  type      = string
  sensitive = true
}

variable "local_computer_ip" {
  type        = string
  description = "IP Address of the computer you are running and testing this example from"
}
