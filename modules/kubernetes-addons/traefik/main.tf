locals {
  name      = try(var.helm_config.name, "traefik")
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

  # https://github.com/traefik/traefik-helm-chart/blob/master/traefik/Chart.yaml
  helm_config = merge(
    {
      name        = local.name
      chart       = local.name
      repository  = "https://helm.traefik.io/traefik"
      version     = "18.1.0"
      namespace   = try(kubernetes_namespace_v1.this[0].metadata[0].name, local.namespace)
      description = "The Traefik Helm Chart is focused on Traefik deployment configuration"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
