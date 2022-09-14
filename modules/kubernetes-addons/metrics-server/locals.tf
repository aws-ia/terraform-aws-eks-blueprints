locals {
  name = "metrics-server"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes-sigs.github.io/metrics-server/"
    version     = "3.8.2"
    namespace   = "kube-system"
    description = "Metric server helm Chart deployment configuration"
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
