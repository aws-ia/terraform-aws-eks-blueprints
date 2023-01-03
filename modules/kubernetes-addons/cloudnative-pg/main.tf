locals {
  name = "cnpg"

  # https://github.com/cloudnative-pg/charts/blob/main/charts/cloudnative-pg/Chart.yaml
  default_helm_config = {
    name             = local.name
    chart            = "cloudnative-pg"
    repository       = "https://cloudnative-pg.github.io/charts"
    version          = "0.16.1"
    namespace        = "cnpg-system"
    create_namespace = true
    values           = [templatefile("${path.module}/values.yaml", {})]
    description      = "CloudNativePG Operator Helm chart deployment configuration"
  }

  helm_config = merge(local.default_helm_config, var.helm_config)
}

#-------------------------------------------------
# Apache Airflow Helm Add-on
#-------------------------------------------------
module "helm_addon" {
  source = "../helm-addon"

  helm_config   = local.helm_config
  addon_context = var.addon_context
}
