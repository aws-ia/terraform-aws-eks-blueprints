module "helm_addon" {
  source            = "../helm-addon"
  helm_config       = local.helm_config
  set_values        = local.set_values
  irsa_config       = local.irsa_config
  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}

resource "kubernetes_namespace_v1" "thanos" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name = local.namespace_name
  }
}
