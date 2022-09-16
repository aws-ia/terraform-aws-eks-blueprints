locals {
  default_helm_config = {
    name             = "local-static-provisioner"
    chart            = "${path.module}/local-static-provisioner"
    version          = "2.6.0-alpha.1"
    namespace        = "local-static-provisioner"
    create_namespace = true
    description      = "local provisioner helm chart configuration"
  }

  default_helm_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    {
      values = distinct(concat(try(var.helm_config["values"], []), local.default_helm_values))
    }
  )
}
