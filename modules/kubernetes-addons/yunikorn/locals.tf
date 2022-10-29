locals {
  name = "yunikorn"

  # https://github.com/apache/yunikorn-release/blob/master/helm-charts/yunikorn/Chart.yaml
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://apache.github.io/yunikorn-release"
    version     = "1.1.0"
    namespace   = local.name
    description = "Apache YuniKorn (Incubating) is a light-weight, universal resource scheduler for container orchestrator systems"
    values      = [file("${path.module}/values.yaml")]
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
