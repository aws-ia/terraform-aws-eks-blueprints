locals {
  name = "secrets-store-csi-driver"

  # https://github.com/kubernetes-sigs/secrets-store-csi-driver/blob/main/charts/secrets-store-csi-driver/Chart.yaml
  default_helm_config = {
    name        = "csi-secrets-store"
    chart       = local.name
    repository  = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
    version     = "1.3.1"
    namespace   = local.name
    description = "A Helm chart to install the Secrets Store CSI Driver"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
