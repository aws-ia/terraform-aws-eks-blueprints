variable "datadog_api_key" {
  type        = string
  default     = ""
  description = "Datadog API key"
}

variable "datadog_operator_helm_config" {
  type        = any
  default     = null
  description = "Helm config for the Datadog operator Helm chart"
}
