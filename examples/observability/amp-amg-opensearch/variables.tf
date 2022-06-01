variable "grafana_endpoint" {
  description = "Grafana endpoint"
  type        = string
  default     = "https://example.com"
}

variable "grafana_api_key" {
  description = "Api key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = ""
  sensitive   = true
}

variable "opensearch_dashboard_user" {
  description = "OpenSearch dashboard user"
  type        = string
  default     = ""
}

variable "opensearch_dashboard_pw" {
  description = "OpenSearch dashboard user password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "create_iam_service_linked_role" {
  description = "Whether to create the AWSServiceRoleForAmazonElasticsearchService role used by the OpenSearch service"
  type        = bool
  default     = true
}
