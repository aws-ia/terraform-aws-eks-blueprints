module "helm_addon" {
  source = "../helm-addon"

  addon_context = var.addon_context
  helm_config   = local.helm_config
  irsa_config   = local.irsa_config
}
