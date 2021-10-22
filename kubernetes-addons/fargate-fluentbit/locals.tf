
locals {

  fargate_fluentbit_cwlog_group         = "/${var.eks_cluster_id}/fargate-fluentbit-logs"
  fargate_fluentbit_cwlog_stream_prefix = "fargate-logs-"

  default_fargate_fluentbit_helm_app = {
    output_conf  = <<EOF
[OUTPUT]
  Name cloudwatch_logs
  Match *
  region ${data.aws_region.current.id}
  log_group_name ${local.fargate_fluentbit_cwlog_group}
  log_stream_prefix ${local.fargate_fluentbit_cwlog_stream_prefix}
  auto_create_group true
    EOF
    filters_conf = <<EOF
[FILTER]
  Name parser
  Match *
  Key_Name log
  Parser regex
  Preserve_Key On
  Reserve_Data On
    EOF
    parsers_conf = <<EOF
[PARSER]
  Name regex
  Format regex
  Regex ^(?<time>[^ ]+) (?<stream>[^ ]+) (?<logtag>[^ ]+) (?<message>.+)$
  Time_Key time
  Time_Format %Y-%m-%dT%H:%M:%S.%L%z
  Time_Keep On
  Decode_Field_As json message
    EOF

  }
  fargate_fluentbit_app = merge(
    local.default_fargate_fluentbit_helm_app,
  var.fargate_fluentbit_config)

}
