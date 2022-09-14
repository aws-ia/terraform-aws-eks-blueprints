locals {
  name = "airflow"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://airflow.apache.org"
    version          = "1.6.0"
    namespace        = local.name
    create_namespace = true
    description      = "Apache Airflow v2 Helm chart deployment configuration"
  }
  default_helm_values = [templatefile("${path.module}/values.yaml", {})]
  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    {
      values = distinct(concat(try(var.helm_config["values"], []), local.default_helm_values))
    }
  )
}

#-------------------------------------------------
# Apache Airflow Helm Add-on
#-------------------------------------------------
module "helm_addon" {
  source        = "../helm-addon"
  helm_config   = local.helm_config
  irsa_config   = null
  addon_context = var.addon_context
}
