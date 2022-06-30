resource "kubernetes_namespace_v1" "csi_secrets_store_provider_aws" {
  metadata {
    name = local.name

    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    }
  }
}

module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  addon_context     = var.addon_context

  depends_on = [kubernetes_namespace_v1.csi_secrets_store_provider_aws]
}
