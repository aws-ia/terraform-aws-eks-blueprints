locals {
  name = "traefik"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://helm.traefik.io/traefik"
    version     = "10.20.1"
    namespace   = local.name
    description = "The Traefik Helm Chart is focused on Traefik deployment configuration"
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
