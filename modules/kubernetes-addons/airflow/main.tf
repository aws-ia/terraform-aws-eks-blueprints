locals {
  name = "airflow"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://airflow.apache.org"
    version     = "1.6.0"
    namespace   = local.name
    values      = [templatefile("${path.module}/values.yaml", {})]
    description = "Apache Airflow v2 Helm chart deployment configuration"
  }

  helm_config = merge(local.default_helm_config, var.helm_config)
}

#-------------------------------------------------
# Apache Airflow Helm Add-on
#-------------------------------------------------
module "helm_addon" {
  source        = "../helm-addon"
  helm_config   = local.helm_config
  irsa_config   = null
  addon_context = var.addon_context

  depends_on = [kubernetes_namespace_v1.airflow]
}

resource "kubernetes_namespace_v1" "airflow" {
  count = try(local.helm_config["create_namespace"], true) && local.helm_config["namespace"] != "kube-system" ? 1 : 0

  metadata {
    name = local.helm_config["namespace"]
  }
}
