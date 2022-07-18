locals {
  name = "kube-prometheus-stack"
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://prometheus-community.github.io/helm-charts"
    version     = "36.0.3"
    namespace   = local.name
    timeout     = "1200"
    values      = local.default_helm_values
    description = "kube-prometheus-stack helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region = var.addon_context.aws_region_name
  })]

}
