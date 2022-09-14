locals {
  name = "yunikorn"
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://apache.github.io/yunikorn-release"
    version     = "1.0.0"
    namespace   = local.name
    description = "Apache YuniKorn (Incubating) is a light-weight, universal resource scheduler for container orchestrator systems"
    timeout     = "1200"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

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
