locals {
  name      = "cert-manager-csi-driver"
  namespace = "cert-manager"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://charts.jetstack.io"
    version     = "v0.4.2"
    namespace   = local.namespace
    description = "Cert Manager CSI Driver Add-on"
    values      = []
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
