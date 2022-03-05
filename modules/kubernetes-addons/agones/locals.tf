
locals {
  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  default_helm_config = {
    name               = "agones"
    chart              = "agones"
    repository         = "https://agones.dev/chart/stable"
    version            = "1.18.0"
    namespace          = "agones-system"
    timeout            = "1200"
    description        = "Agones Gaming Server Helm Chart deployment configuration"
    values             = local.default_helm_values
    gameserver_minport = 7000
    gameserver_maxport = 8000
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
