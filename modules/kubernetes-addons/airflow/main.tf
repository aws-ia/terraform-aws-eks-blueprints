locals {
  name = "airflow"

  # https://github.com/apache/airflow/blob/main/chart/Chart.yaml
  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://airflow.apache.org"
    version          = "1.7.0"
    namespace        = local.name
    create_namespace = true
    values           = [templatefile("${path.module}/values.yaml", {})]
    description      = "Apache Airflow v2 Helm chart deployment configuration"
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
