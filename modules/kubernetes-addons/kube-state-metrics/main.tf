locals {
  name = "kube-state-metrics"
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-state-metrics/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://prometheus-community.github.io/helm-charts"
      version          = "4.29.0"
      namespace        = local.name
      create_namespace = true
      description      = "Kube State Metrics helm Chart deployment configuration"
    },
    var.helm_config
  )

  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
}
