locals {
  name = "robusta"
}

module "helm_addon" {

  source = "../helm-addon"

  # https://github.com/robusta-dev/robusta/blob/master/helm/robusta/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://robusta-charts.storage.googleapis.com"
      version          = "v0.10.13"
      namespace        = local.name
      create_namespace = true
      description      = "Robusta Helm Chart deployment configuration"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
