locals {
  name = "vpa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://charts.fairwinds.com/stable"
    version     = "1.4.0"
    namespace   = local.name
    description = "Kubernetes Vertical Pod Autoscaler"
    timeout     = "1200"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    { values = distinct(concat(try(var.helm_config["values"], []), local.default_helm_values)) }
  )

  argocd_gitops_config = {
    enable = true
  }
}
