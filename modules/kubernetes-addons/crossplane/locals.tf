locals {
  namespace = "crossplane-system"

  default_helm_config = {
    name        = "crossplane"
    chart       = "crossplane"
    repository  = "https://charts.crossplane.io/stable/"
    version     = "1.6.2"
    namespace   = local.namespace
    description = "Crossplane Helm chart"
    values      = local.default_helm_values
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    operating-system = "linux"
  })]

  argocd_gitops_config = {
    enable = true
  }
}
