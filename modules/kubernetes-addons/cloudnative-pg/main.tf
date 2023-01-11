locals {
  name = "cnpg"
  default_helm_config = {
    name             = local.name
    chart            = "cloudnative-pg"
    repository       = "https://cloudnative-pg.github.io/charts"
    version          = "0.16.1"
    namespace        = "${local.name}-system"
    create_namespace = true
    values           = [templatefile("${path.module}/values.yaml", {})]
    description      = "CloudNativePG Operator Helm chart deployment configuration"
  }

  helm_config = merge(local.default_helm_config, var.helm_config)
}

#-------------------------------------------------
# CloudNative PG Helm Add-on
#-------------------------------------------------
module "helm_addon" {
  source        = "../helm-addon"
  helm_config   = local.helm_config
  addon_context = var.addon_context
}
