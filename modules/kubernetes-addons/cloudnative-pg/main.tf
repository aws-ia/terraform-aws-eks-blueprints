locals {
  name = "cnpg"
}

#-------------------------------------------------
# Apache Airflow Helm Add-on
#-------------------------------------------------
module "helm_addon" {
  source = "../helm-addon"

  helm_config = {
    name             = local.name
    chart            = "cloudnative-pg"
    repository       = "https://cloudnative-pg.github.io/charts"
    version          = "0.16.1"
    namespace        = "cnpg-system"
    create_namespace = true
    values           = [templatefile("${path.module}/values.yaml", {})]
    description      = "CloudNativePG Operator Helm chart deployment configuration"
  }
  addon_context = var.addon_context
}
