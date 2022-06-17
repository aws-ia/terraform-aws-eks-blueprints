locals {
  name = "kubernetes-dashboard"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes.github.io/dashboard/"
    version     = "5.7.0"
    namespace   = local.name
    description = "Kubernetes Dashboard Helm Chart"
    values      = []
    timeout     = "1200"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
