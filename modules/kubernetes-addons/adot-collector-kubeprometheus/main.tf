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