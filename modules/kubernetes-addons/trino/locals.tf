locals {
  name = "trino"

  # https://github.com/trinodb/charts/blob/main/charts/trino/Chart.yaml 
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://trinodb.github.io/charts/"
    version     = "0.9.0"
    namespace   = local.name
    description = "Trino Community Kubernetes Helm Chart"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
