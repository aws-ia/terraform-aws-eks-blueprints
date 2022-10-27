locals {
  name      = "agones"
  namespace = "agones-system"

  # https://github.com/googleforgames/agones/blob/main/install/helm/agones/Chart.yaml
  default_helm_config = {
    name               = local.name
    chart              = local.name
    repository         = "https://agones.dev/chart/stable"
    version            = "1.27.0"
    namespace          = local.namespace
    description        = "Agones Gaming Server Helm Chart deployment configuration"
    values             = local.default_helm_values
    gameserver_minport = 7000
    gameserver_maxport = 8000
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
