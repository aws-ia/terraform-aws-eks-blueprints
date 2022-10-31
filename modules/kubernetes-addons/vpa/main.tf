locals {
  name      = try(var.helm_config.name, "vpa")
  namespace = try(var.helm_config.namespace, local.name)
}

resource "kubernetes_namespace_v1" "vpa" {
  count = try(var.helm_config.create_namespace, true) && local.namespace != "kube-system" ? 1 : 0

  metadata {
    name = local.namespace
  }
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/FairwindsOps/charts/blob/master/stable/vpa/Chart.yaml
  helm_config = merge(
    {
      name        = local.name
      chart       = local.name
      repository  = "https://charts.fairwinds.com/stable"
      version     = "1.5.0"
      namespace   = try(kubernetes_namespace_v1.vpa[0].metadata[0].name, local.namespace)
      description = "Kubernetes Vertical Pod Autoscaler"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
