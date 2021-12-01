data "aws_region" "current" {}

locals {
  default_aws_open_telemetry_helm_app = {
    aws_open_telemetry_namespace                        = "aws-otel-eks"
    aws_open_telemetry_emitter_otel_resource_attributes = "service.namespace=AWSObservability,service.name=ADOTEmitService"
    aws_open_telemetry_emitter_name                     = "trace-emitter"
    aws_open_telemetry_emitter_image                    = "public.ecr.aws/g9c4k4i4/trace-emitter:1"
    aws_open_telemetry_collector_image                  = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
    aws_open_telemetry_aws_region                       = "eu-west-1"
    aws_open_telemetry_emitter_oltp_endpoint            = "localhost:55680"
    aws_open_telemetry_mg_node_iam_role_arns            = []
    aws_open_telemetry_self_mg_node_iam_role_arns       = []
  }

  aws_open_telemetry_app = merge(
    local.default_aws_open_telemetry_helm_app,
    var.aws_open_telemetry_addon
  )

  argocd_gitops_config = {
    enable = true
  }
}
