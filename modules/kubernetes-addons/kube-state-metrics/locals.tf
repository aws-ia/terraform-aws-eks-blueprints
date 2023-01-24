locals {
  name = "kube-state-metrics"

  # https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-state-metrics/Chart.yaml
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://prometheus-community.github.io/helm-charts"
    version     = "4.29.0"
    namespace   = "kube-system"
    description = "Kube State Metrics helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
