locals {
  name = "reloader"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://stakater.github.io/stakater-charts"
    version          = "v0.0.118"
    namespace        = local.name
    create_namespace = true
    description      = "Reloader Helm Chart deployment configuration"
  }

  default_helm_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    { values = distinct(concat(try(var.helm_config["values"], []), local.default_helm_values)) }
  )


  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.name
  }
}
