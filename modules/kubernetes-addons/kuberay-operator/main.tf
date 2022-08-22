locals {
  name      = "kuberay-operator"
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
      chart       = "${path.module}/kuberay-operator-config"
      version     = "0.1.0"
      namespace   = kubernetes_namespace_v1.this.metadata[0].name
      description = "KubeRay Operator Helm Chart deployment configuration"
    },
    var.helm_config
  )

  irsa_config   = null
  addon_context = var.addon_context
}
