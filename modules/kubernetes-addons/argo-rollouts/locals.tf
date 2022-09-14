locals {
  name = "argo-rollouts"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://argoproj.github.io/argo-helm"
    version     = "2.16.0"
    namespace   = local.name
    description = "Argo Rollouts AddOn Helm Chart"
    timeout     = "1200"
  }

  default_helm_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    { values = distinct(concat(try(var.helm_config["values"], []), local.default_helm_values)) }
  )

  argocd_gitops_config = {
    enable = true
  }
}
