locals {
  name = "spark-operator"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
    version     = "1.1.25"
    namespace   = local.name
    description = "The spark_k8s_operator HelmChart Ingress Controller deployment configuration"
    timeout     = "1200"
  }

  default_helm_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    { values = distinct(concat(try(var.helm_config["values"], []), local.default_helm_values)) }
  )


  argocd_gitops_config = {
    enable = true
  }
}
