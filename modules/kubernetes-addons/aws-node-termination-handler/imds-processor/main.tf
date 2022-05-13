module "helm_addon" {
  source        = "../../helm-addon"
  helm_config   = local.helm_config
  irsa_config   = null
  addon_context = var.addon_context
}
