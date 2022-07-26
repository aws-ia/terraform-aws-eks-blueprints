variable "opensearch_dashboard_user" {
  description = "OpenSearch dashboard user"
  type        = string
  default     = "aws_demo"
}

variable "opensearch_dashboard_pw" {
  description = "OpenSearch dashboard user password"
  type        = string
  default     = "AWSDemo123!"
  sensitive   = true
}
