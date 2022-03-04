locals {
  name                                = "spark-operator"
  spark_service_account_name          = "spark-sa"
  spark_operator_service_account_name = "spark-operator-sa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
    version     = "1.1.19"
    namespace   = local.name
    description = "The spark_k8s_operator HelmChart Ingress Controller deployment configuration"
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    spark-sa-name          = local.spark_service_account_name
    spark-operator-sa-name = local.spark_operator_service_account_name
  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccounts.spark.name"
      value = local.spark_service_account_name
    },
    {
      name  = "serviceAccounts.spark.create"
      value = false
    },
    {
      name  = "serviceAccounts.sparkoperator.name"
      value = local.spark_operator_service_account_name
    },
    {
      name  = "serviceAccounts.sparkoperator.create"
      value = false
    }
  ]

  argocd_gitops_config = {
    enable = true
    serviceAccountNames = {
      sparkServiceAccount         = local.spark_service_account_name
      sparkOperatorServiceAccount = local.spark_operator_service_account_name
    }
  }
}