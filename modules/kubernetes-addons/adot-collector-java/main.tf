locals {
  name      = "adot-collector-java"
  namespace = try(var.helm_config.namespace, local.name)
}

data "aws_partition" "current" {}

module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge(
    {
      name        = local.name
      chart       = "${path.module}/otel-config"
      version     = "0.2.0"
      namespace   = local.namespace
      description = "ADOT helm Chart deployment configuration"
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "ampurl"
      value = "${var.amazon_prometheus_workspace_endpoint}api/v1/remote_write"
    },
    {
      name  = "region"
      value = var.amazon_prometheus_workspace_region
    },
    {
      name  = "prometheusMetricsEndpoint"
      value = "metrics"
    },
    {
      name  = "prometheusMetricsPort"
      value = 8888
    },
    {
      name  = "scrapeInterval"
      value = "15s"
    },
    {
      name  = "scrapeTimeout"
      value = "10s"
    },
    {
      name  = "scrapeSampleLimit"
      value = 1000
    }
  ]

  irsa_config = {
    create_kubernetes_namespace         = try(var.helm_config["create_namespace"], true)
    kubernetes_namespace                = local.namespace
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(var.helm_config["create_service_account_secret_token"], false)
    kubernetes_service_account          = try(var.helm_config.service_account, local.name)
    irsa_iam_policies                   = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"]
  }

  addon_context = var.addon_context
}
