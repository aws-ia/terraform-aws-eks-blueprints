locals {
  name = "promtail"
  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://grafana.github.io/helm-charts"
    version          = "6.3.0"
    namespace        = try(var.helm_config["namespace"], local.name)
    timeout          = "1200"
    values           = []
    create_namespace = true
    description      = "Promtail helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
