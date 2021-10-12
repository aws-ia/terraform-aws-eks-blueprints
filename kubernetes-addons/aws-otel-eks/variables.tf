
variable "aws_open_telemetry_namespace" {
  default     = "aws-otel-eks"
  description = "WS Open telemetry namespace"
}

variable "aws_open_telemetry_emitter_otel_resource_attributes" {
  description = "AWS Open telemetry emitter otel resource attributes"
}

variable "aws_open_telemetry_emitter_name" {
  description = "AWS Open telemetry emitter image name"
}

variable "aws_open_telemetry_emitter_image" {
  description = "AWS Open telemetry emitter image id and tag"
}

variable "aws_open_telemetry_collector_image" {
  description = "AWS Open telemetry collector image id and tag"
}

variable "aws_open_telemetry_aws_region" {
  description = "AWS Open telemetry region"
}

variable "aws_open_telemetry_emitter_oltp_endpoint" {
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
