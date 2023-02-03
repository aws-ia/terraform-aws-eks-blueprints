# Help on Fargate Logging with Fluentbit and CloudWatch
# https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html

resource "kubernetes_namespace" "aws_observability" {
  metadata {
    name = "aws-observability"

    labels = {
      aws-observability = "enabled"
    }
  }
}

# fluent-bit-cloudwatch value as the name of the CloudWatch log group that is automatically created as soon as your apps start logging
resource "kubernetes_config_map" "aws_logging" {
  metadata {
    name      = "aws-logging"
    namespace = kubernetes_namespace.aws_observability.id
  }

  data = {
    "parsers.conf" = local.config["parsers_conf"]
    "filters.conf" = local.config["filters_conf"]
    "output.conf"  = local.config["output_conf"]
    "flb_log_cw"   = local.config["flb_log_cw"]
  }
}
