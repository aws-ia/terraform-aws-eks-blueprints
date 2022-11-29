locals {
  name = "consul"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://helm.releases.hashicorp.com"
    version          = "1.0.1"
    namespace        = local.name
    create_namespace = true
    description      = "Consul helm Chart deployment configuration"
    values           = [templatefile("${path.module}/values.yaml", {})]
  }

  helm_config = merge(local.default_helm_config, var.helm_config)

  argocd_gitops_config = {
    enable = true
  }
}
