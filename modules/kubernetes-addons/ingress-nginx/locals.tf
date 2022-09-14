locals {
  name = "ingress-nginx"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://kubernetes.github.io/ingress-nginx"
    version          = "4.1.4"
    namespace        = local.name
    create_namespace = true
    set              = []
    description      = "The NGINX HelmChart Ingress Controller deployment configuration"
    wait             = false
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    { values = distinct(concat(try(var.helm_config["values"], []), local.default_helm_values)) }
  )

  argocd_gitops_config = {
    enable = true
  }
}
