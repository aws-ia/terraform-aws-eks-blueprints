locals {
  name = "strimzi"
  default_helm_config = {
    name             = local.name
    chart            = "strimzi-kafka-operator"
    repository       = "https://strimzi.io/charts/"
    version          = "0.31.1"
    namespace        = local.name
    create_namespace = true
    values           = [templatefile("${path.module}/values.yaml", {})]
    description      = "Strimzi - Apache Kafka on Kubernetes"
  }
  helm_config = merge(local.default_helm_config, var.helm_config)
}

#-------------------------------------------------
# Strimzi Kafka Helm Add-on
#-------------------------------------------------
module "helm_addon" {
  source            = "../helm-addon"
  helm_config       = local.helm_config
  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
}
