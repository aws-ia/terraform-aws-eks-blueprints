resource "kubernetes_namespace_v1" "secrets_store_csi_driver" {
  count = try(var.helm_config.create_namespace, true) ? 1 : 0

  metadata {
    name = local.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    }
  }
}

module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config = merge(
    {
      namespace = try(kubernetes_namespace_v1.secrets_store_csi_driver[0].metadata[0].name, local.namespace)
    },
    local.helm_config
  )
  addon_context = var.addon_context
}
