
variable "aws_open_telemetry_namespace" {
  default     = "aws-otel-eks"
  description = "WS Open telemetry namespace"
}

variable "aws_open_telemetry_emitter_image" {
  default     = "aottestbed/aws-otel-collector-sample-app:java-0.1.0"
  description = "AWS Open telemetry emitter image id and tag"
}

variable "aws_open_telemetry_collector_image" {
  default     = "amazon/aws-otel-collector:latest"
  description = "AWS Open telemetry collector image id and tag"
}

variable "aws_open_telemetry_aws_region" {
  description = "AWS Open telemetry region"
}

variable "aws_open_telemetry_oltp_endpoint" {
  default     = "localhost:4317"
  description = "AWS Open telemetry OLTP endpoint"
}

variable "aws_open_telemetry_mg_node_iam_role_arns" {
  type    = list(string)
  default = []
}

variable "aws_open_telemetry_self_mg_node_iam_role_arns" {
  type    = list(string)
  default = []
}

