locals {

  cwlog_group         = "/${var.addon_context.eks_cluster_id}/fargate-fluentbit-logs"
  cwlog_stream_prefix = "fargate-logs-"

  default_config = {
    output_conf  = <<-EOF
    [OUTPUT]
      Name cloudwatch_logs
      Match *
      region ${var.addon_context.aws_region_name}
      log_group_name ${local.cwlog_group}
      log_stream_prefix ${local.cwlog_stream_prefix}
      auto_create_group true
    EOF
    filters_conf = <<-EOF
    [FILTER]
      Name parser
      Match *
      Key_Name log
      Parser regex
      Preserve_Key True
      Reserve_Data True
    EOF
    parsers_conf = <<-EOF
    [PARSER]
      Name regex
      Format regex
      Regex ^(?<time>[^ ]+) (?<stream>[^ ]+) (?<logtag>[^ ]+) (?<message>.+)$
      Time_Key time
      Time_Format %Y-%m-%dT%H:%M:%S.%L%z
      Time_Keep On
      Decode_Field_As json message
    EOF
    flb_log_cw   = false
  }

  config = merge(
    local.default_config,
    var.addon_config
  )
}
