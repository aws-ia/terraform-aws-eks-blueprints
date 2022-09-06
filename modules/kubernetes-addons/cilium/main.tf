module "helm_addon" {
  source            = "../helm-addon"
  helm_config       = local.helm_config
  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
