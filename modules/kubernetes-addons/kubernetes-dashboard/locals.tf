locals {
  name = "kubernetes-dashboard"

  # https://github.com/kubernetes/dashboard/blob/master/charts/helm-chart/kubernetes-dashboard/Chart.yaml
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes.github.io/dashboard/"
    version     = "5.11.0"
    namespace   = local.name
    description = "Kubernetes Dashboard Helm Chart"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
