locals {
  name = "reloader"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://stakater.github.io/stakater-charts"
    version          = "v0.0.118"
    namespace        = local.name
    create_namespace = true
    values           = []
    description      = "Reloader Helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )


  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.name
  }
}
