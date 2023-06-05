module "helm_addon" {
  source = "../helm-addon"

  addon_context = var.addon_context
  set_values    = local.set_values
  helm_config   = local.helm_config
}
