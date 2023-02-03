locals {
  default_helm_config = {
    name             = "local-static-provisioner"
    chart            = "${path.module}/local-static-provisioner"
    version          = "2.6.0-alpha.1"
    namespace        = "local-static-provisioner"
    create_namespace = true
    description      = "local provisioner helm chart configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )
}
