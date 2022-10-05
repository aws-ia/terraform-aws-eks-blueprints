locals {
  name = "consul"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://helm.releases.hashicorp.com"
    version          = "0.49.0"
    namespace        = local.name
    create_namespace = true
    description      = "Consul helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
