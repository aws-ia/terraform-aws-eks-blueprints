locals {
  name      = "sysdig"
  namespace = "sysdig"

  set_values = []

  default_helm_config = {
    name             = local.name
    chart            = "sysdig-deploy"
    repository       = "https://charts.sysdig.com"
    version          = "1.5.71"
    namespace        = local.namespace
    create_namespace = true
    values           = local.default_helm_values
    set              = []
    description      = "Sysdig HelmChart Sysdig-Deploy configuration"
    wait             = false
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values-sysdig.yaml", {}, )]

}
