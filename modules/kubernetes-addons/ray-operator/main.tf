locals {
  name      = "ray-operator"
  namespace = try(var.helm_config.namespace, local.name)
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = local.namespace
  }
}

module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge(
    {
      name        = local.name
      chart       = "${path.module}/ray-operator-config"
      version     = "0.2.0"
      namespace   = local.namespace
      description = "Ray Operator Helm Chart deployment configuration"
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "operatorOnly"
      value = "true"
    },
    {
      name  = "operatorNamespace"
      value = local.namespace
    }
  ]

  irsa_config   = null
  addon_context = var.addon_context

  depends_on = [kubernetes_namespace_v1.this]
}
