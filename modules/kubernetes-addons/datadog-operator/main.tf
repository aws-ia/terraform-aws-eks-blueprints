locals {
  name = "datadog-operator"
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/DataDog/helm-charts/blob/main/charts/datadog-operator/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://helm.datadoghq.com"
      version          = "1.0.2"
      namespace        = local.name
      create_namespace = true
      description      = "Datadog Operator"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops

  addon_context = var.addon_context
}
