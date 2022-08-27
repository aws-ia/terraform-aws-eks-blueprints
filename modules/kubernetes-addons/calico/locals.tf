locals {
  name = "calico"
  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://projectcalico.docs.tigera.io/charts"
    version          = "v3.24.0"
    namespace        = "tigera-operator"
    values           = local.default_helm_values
    create_namespace = true
    description      = "calico helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region = var.addon_context.aws_region_name
  })]

  argocd_gitops_config = {
    enable = true
  }
}
