locals {
  name = "vpa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://charts.fairwinds.com/stable"
    version     = "1.4.0"
    namespace   = local.name
    description = "Kubernetes Vertical Pod Autoscaler"
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
