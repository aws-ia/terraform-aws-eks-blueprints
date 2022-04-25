resource "kubernetes_namespace" "csi_secrets_store_provider_aws" {
  metadata {
    name = local.name
  }
}

module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  addon_context     = var.addon_context

  depends_on = [kubernetes_namespace.csi_secrets_store_provider_aws]
}