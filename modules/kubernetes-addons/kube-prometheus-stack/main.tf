locals {
  name             = try(var.helm_config.name, "kube-prometheus-stack")
  namespace_name   = try(var.helm_config.namespace, local.name)
  create_namespace = try(var.helm_config.create_namespace, true) && local.namespace_name != "kube-system"
  namespace        = local.create_namespace ? kubernetes_namespace_v1.prometheus[0].metadata[0].name : local.namespace_name

  argocd_gitops_config = {
    enable = true
  }
}

resource "kubernetes_namespace_v1" "prometheus" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name = local.namespace
  }
}

# https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/Chart.yaml
module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge(
    {
      name       = local.name
      chart      = local.name
      repository = "https://prometheus-community.github.io/helm-charts"
      version    = "41.6.1"
      namespace  = local.namespace
      values = [templatefile("${path.module}/values.yaml", {
        aws_region = var.addon_context.aws_region_name
      })]
      description = "kube-prometheus-stack helm Chart deployment configuration"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
