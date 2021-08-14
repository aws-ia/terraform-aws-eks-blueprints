variable "opentelemetry_enable_standalone_collector" {
  type        = bool
  default     = false
  description = "Enabling the opentelemetry standalone gateway collector on eks cluster"
}

variable "opentelemetry_enable_agent_collector" {
  type        = bool
  default     = true
  description = "Enabling the opentelemetry agent collector on eks cluster"
}

variable "opentelemetry_enable_autoscaling_standalone_collector" {
  type        = bool
  default     = false
  description = "Enabling the autoscaling of the standalone gateway collector on eks cluster"
}
variable "opentelemetry_image_tag" {
  default     = "0.31.0"
  description = "Docker image tag for opentelemetry from open-telemetry"
}

variable "opentelemetry_image" {
  default     = "otel/opentelemetry-collector"
  description = "Docker image for opentelemetry from open-telemetry"
}

variable "opentelemetry_helm_chart_version" {
  default     = "0.5.9"
  description = "Helm chart version for opentelemetry"
}

variable "opentelemetry_helm_chart" {
  default     = "open-telemetry/opentelemetry-collector"
  description = "Helm chart for opentelemetry"
}

variable "opentelemetry_command_name" {
  default     = "otel"
  description = "The OpenTelemetry command.name value"
}

variable "opentelemetry_enable_container_logs" {
  default     = false
  description = "Whether or not to enable container log collection on the otel agents"
}

variable "opentelemetry_min_standalone_collectors" {
  default     = 1
  description = "The minimum number of opentelemetry standalone gateway collectors to run"
}

variable "opentelemetry_max_standalone_collectors" {
  default     = 3
  description = "The maximum number of opentelemetry standalone gateway collectors to run"
}

variable "private_container_repo_url" {}

variable "public_docker_repo" {}
