locals {
  name      = try(var.helm_config.name, "ingress-nginx")
  namespace = try(var.helm_config.namespace, local.name)
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
      name        = local.name
      chart       = local.name
      repository  = "https://kubernetes.github.io/ingress-nginx"
      version     = "4.1.4"
      namespace   = try(kubernetes_namespace_v1.this[0].metadata[0].name, local.namespace)
      description = "The NGINX HelmChart Ingress Controller deployment configuration"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
