locals {
  default_helm_config = {
    name             = "calico"
    chart            = "tigera-operator"
    repository       = "https://docs.projectcalico.org/charts"
    version          = "v3.24.1"
    namespace        = "tigera-operator"
    values           = local.default_helm_values
    create_namespace = true
    description      = "calico helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  argocd_gitops_config = {
    enable = true
  }
}
