# Deploys HAproxy collector
module "helm_addon" {
  source        = "../helm-addon"
  set_values    = local.otel_config_values
  helm_config   = local.helm_config
  irsa_config   = local.adot_collector_irsa_config
  addon_context = var.addon_context

  depends_on = [kubernetes_namespace_v1.collector]
}

resource "kubernetes_namespace_v1" "collector" {
  metadata {
    name = local.helm_config["namespace"]
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    }
  }
}
