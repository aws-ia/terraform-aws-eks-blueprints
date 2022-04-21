locals {
  name = "ingress-nginx"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://kubernetes.github.io/ingress-nginx"
    version          = "4.0.17"
    namespace        = local.name
    create_namespace = false
    values           = local.default_helm_values
    set              = []
    description      = "The NGINX HelmChart Ingress Controller deployment configuration"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
