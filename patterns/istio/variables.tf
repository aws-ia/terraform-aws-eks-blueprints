variable "istio_chart_version" {
  description = "The version of the Istio Helm chart to deploy. This specifies which version of Istio components to use."
  type        = string
  default     = "1.22.0"
}

variable "istio_chart_url" {
  description = "The URL of the repository where the Istio Helm charts are stored. This specifies the location from which the Istio charts will be fetched."
  type        = string
  default     = "https://istio-release.storage.googleapis.com/charts"
}

variable "enable_ambient_mode" {
  description = "Enable Istio Ambient mode"
  type        = bool
  default     = false
}
