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
    values           = local.default_helm_values
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
