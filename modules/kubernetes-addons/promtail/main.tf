module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/grafana/helm-charts/blob/main/charts/promtail/Chart.yaml
  helm_config = merge(
    {
      name             = "promtail"
      chart            = "promtail"
      repository       = "https://grafana.github.io/helm-charts"
      version          = "6.6.0"
      namespace        = "promtail"
      create_namespace = true
      description      = "Promtail helm Chart deployment configuration"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
