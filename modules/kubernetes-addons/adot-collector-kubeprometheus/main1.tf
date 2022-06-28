locals {
  name      = "adot-collector-kubeprometheus"
  namespace = try(var.helm_config.namespace, local.name)
}
resource "helm_release" "kube_state_metrics" {
  count            = var.enabled_kube_state_metrics ? 1 : 0
  chart            = var.helm_chart_name_ksm
  create_namespace = var.helm_create_namespace_ksm
  namespace        = var.k8s_namespace_ksm
  name             = var.helm_release_name_ksm
  version          = var.helm_chart_version_ksm
  repository       = var.helm_repo_url_ksm

  values = [
    var.values
  ]

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "prometheus_node_exporter" {
  count            = var.enabled_node_exporter ? 1 : 0
  chart            = var.helm_chart_name_ne
  create_namespace = var.helm_create_namespace
  namespace        = var.k8s_namespace_ne
  name             = var.helm_release_name_ne
  version          = var.helm_chart_version_ne
  repository       = var.helm_repo_url_ne

  values = [
    var.values
  ]

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }
}
data "aws_partition" "current" {}

module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge(
    {
      name        = local.name
      chart       = "${path.module}/otel-config-adot"
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
    create_kubernetes_namespace       = true
    kubernetes_namespace              = local.namespace
    create_kubernetes_service_account = true
    kubernetes_service_account        = try(var.helm_config.service_account, local.name)
    irsa_iam_policies                 = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"]
  }

  addon_context = var.addon_context
}
