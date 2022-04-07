module "certificate" {
  source            = "../cert-manager"
  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
}

module "operator" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  irsa_config       = null
  addon_context     = var.addon_context

  depends_on = [module.certificate, kubernetes_namespace_v1.prometheus]
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata {
    name = local.helm_config["namespace"]
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    }
  }
}
