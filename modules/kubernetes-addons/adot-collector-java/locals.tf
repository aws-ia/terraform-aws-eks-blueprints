locals {
  name                           = "adot-collector-java"
  adot_collector_service_account = "adot-collector-java"

  default_helm_config = {
    name        = local.name
    repository  = null
    chart       = "${path.module}/otel-config"
    version     = "0.2.0"
    namespace   = local.name
    timeout     = "1200"
    description = "ADOT helm Chart deployment configuration"
    lint        = false
    values      = []
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  otel_config_values = [
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

  adot_collector_irsa_config = {
    kubernetes_namespace              = local.name
    create_kubernetes_namespace       = false
    kubernetes_service_account        = local.adot_collector_service_account
    create_kubernetes_service_account = true
    irsa_iam_policies                 = ["arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"]
  }
}
