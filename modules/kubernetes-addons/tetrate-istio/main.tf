module "base" {
  source = "../helm-addon"

  count = var.install_base ? 1 : 0

  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.base_helm_config
  addon_context     = var.addon_context
}

module "cni" {
  source = "../helm-addon"

  count = var.install_cni ? 1 : 0

  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.cni_helm_config
  addon_context     = var.addon_context

  depends_on = [module.base]
}

module "istiod" {
  source = "../helm-addon"

  count = var.install_istiod ? 1 : 0

  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.istiod_helm_config
  addon_context     = var.addon_context

  depends_on = [module.cni]
}

module "gateway" {
  source = "../helm-addon"

  count = var.install_gateway ? 1 : 0

  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.gateway_helm_config
  addon_context     = var.addon_context

  depends_on = [module.istiod]
}
