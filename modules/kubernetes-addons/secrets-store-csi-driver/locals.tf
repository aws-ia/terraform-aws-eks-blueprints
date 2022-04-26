locals {
  name                 = "secrets-store-csi-driver"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
    version     = "1.1.2"
    namespace   = local.name
    description = "A Helm chart to install the Secrets Store CSI Driver "
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = [
    {
      name  = "enableSecretRotation"
      value = "true"
    },
    {
      name  = "syncSecret.enabled"
      value = "true"
    }
  ]

  argocd_gitops_config = {
    enable             = true
  }
}