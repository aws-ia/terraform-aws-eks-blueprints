variable "datadog_api_key" {
  type        = string
  description = "API keyfor sending metrics to Datadog"
}

variable "datadog_site" {
  type        = string
  description = "Datadog host to send metrics to, see https://docs.datadoghq.com/getting_started/site/"
  default     = "datadoghq.com"
}
