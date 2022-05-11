module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  irsa_config       = null
  addon_context     = var.addon_context

  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_namespace_v1" "this" {
  count = local.helm_config["namespace"] == "kube-system" ? 0 : 1

  metadata {
    name = local.helm_config["namespace"]
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    }
  }
}
