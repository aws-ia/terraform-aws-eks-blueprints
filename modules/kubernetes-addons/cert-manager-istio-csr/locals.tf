locals {
  name = "kubecost"

  default_helm_config = {
    name        = local.name
    chart       = "cert-manager-istio-csr"
    repository  = "https://charts.jetstack.io"
    version     = "v0.5.0"
    namespace   = local.name
    values      = null
    description = "Cert-manager-istio-csr Helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
