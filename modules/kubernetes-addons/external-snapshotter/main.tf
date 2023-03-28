locals {
  name          = "snapshot-controller"
  namespace     = try(var.helm_config.namespace, local.name)
  name_override = try(var.helm_config.nameOverride, local.name)
  replicas      = try(var.helm_config.replicas, 2)
}

module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge(
    {
      name        = local.name
      chart       = "${path.module}/snapshot-controller"
      version     = "0.0.1"
      namespace   = local.namespace
      description = "Snapshot Controller helm Chart deployment configuration"
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "namespace"
      value = local.namespace
    },
    {
      name  = "nameOverride"
      value = local.name_override
    },
    {
      name  = "replicas"
      value = local.replicas
    }
  ]

  addon_context = var.addon_context
}
