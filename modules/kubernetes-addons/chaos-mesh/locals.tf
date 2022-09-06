locals {
  name = "chaos-mesh"
  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://charts.chaos-mesh.org"
    version          = "2.3.1"
    namespace        = "chaos-testing"
    create_namespace = true
    description      = "chaos mesh helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
