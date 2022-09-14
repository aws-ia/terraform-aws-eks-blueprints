locals {
  name = "promtail"
  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://grafana.github.io/helm-charts"
    version          = "6.3.0"
    namespace        = local.name
    create_namespace = true
    description      = "Promtail helm Chart deployment configuration"
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
