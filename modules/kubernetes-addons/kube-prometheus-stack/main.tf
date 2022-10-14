module "helm_addon" {
  source        = "../helm-addon"
  helm_config   = local.helm_config
  addon_context = var.addon_context
}

resource "kubernetes_namespace_v1" "prometheus" {
  count = local.create_namespace ? 1 : 0
  metadata {
    name = local.namespace_name
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    }
  }
}
