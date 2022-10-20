locals {
  name = "kong"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://charts.konghq.com"
    version          = "2.13.1"
    namespace        = local.name
    create_namespace = true
    values           = local.default_helm_values
    set              = [
        {
            name  = "ingressController.installCRDs"
            value = false
        }
    ]
    description      = "The Kong Ingress Helm Chart configuration"
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
