locals {
  name = "traefik"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://helm.traefik.io/traefik"
    version     = "10.20.1"
    namespace   = local.name
    description = "The Traefik Helm Chart is focused on Traefik deployment configuration"
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
