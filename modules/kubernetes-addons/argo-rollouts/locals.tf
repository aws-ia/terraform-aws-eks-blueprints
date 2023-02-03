locals {
  name = "argo-rollouts"

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-rollouts/Chart.yaml
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://argoproj.github.io/argo-helm"
    version     = "2.21.1"
    namespace   = local.name
    description = "Argo Rollouts AddOn Helm Chart"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
