locals {
  name = "kubernetes-dashboard"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes.github.io/dashboard/"
    version     = "5.7.0"
    namespace   = local.name
    description = "Kubernetes Dashboard Helm Chart"
    timeout     = "1200"
  }

  default_helm_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    {
      values = distinct(concat(try(var.helm_config["values"], []), local.default_helm_values))
    }
  )

  argocd_gitops_config = {
    enable = true
  }
}
