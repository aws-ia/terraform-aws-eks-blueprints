locals {
  name = "metrics-server"

  # https://github.com/kubernetes-sigs/metrics-server/blob/master/charts/metrics-server/Chart.yaml
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes-sigs.github.io/metrics-server/"
    version     = "3.8.2"
    namespace   = "kube-system"
    description = "Metric server helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
