locals {
  name      = try(var.helm_config.name, "rancher")
  namespace = try(var.helm_config.namespace, "cattle-system")
}

resource "kubernetes_namespace_v1" "this" {
  count = try(var.helm_config.create_namespace, true) && local.namespace != "kube-system" ? 1 : 0

  metadata {
    name = local.namespace
  }
}

module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge(
    {
      name                        = local.name
      chart                       = local.name
      repository                  = "https://releases.rancher.com/server-charts/stable"
      version                     = var.helm_config.version
      namespace                   = try(kubernetes_namespace_v1.this[0].metadata[0].name, local.namespace)
      description                 = "The Rancher HelmChart deployment configuration"
      create_kubernetes_namespace = true
      values = [templatefile("${path.module}/values.yaml", {
        hostname                 = var.helm_config.hostname
        bootstrapPassword        = var.helm_config.bootstrapPassword
        ingress_tls_source       = var.helm_config.ingress_tls_source
        ingress_ingressClassName = var.helm_config.ingress_ingressClassName
      })]
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
