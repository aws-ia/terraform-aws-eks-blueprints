resource "kubernetes_namespace_v1" "irsa" {
  metadata {
    name = local.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    }
  }
}

module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  irsa_config       = null

  depends_on = [kubernetes_namespace_v1.irsa]
}
