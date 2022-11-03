locals {
  name = "argocd-apps"

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-rollouts/Chart.yaml
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://argoproj.github.io/argo-helm"
    version     = "0.0.3"
    namespace   = "argocd"
    description = "Argocd apps AddOn Helm Chart"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
