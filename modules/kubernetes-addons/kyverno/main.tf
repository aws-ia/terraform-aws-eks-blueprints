module "kyverno_helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.kyverno_helm_config
  irsa_config       = null
  addon_context     = var.addon_context
}

module "kyverno_policies_helm_addon" {
  count             = var.enable_kyverno_policies ? 1 : 0
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.kyverno_policies_helm_config
  irsa_config       = null
  addon_context     = var.addon_context
  depends_on        = [module.kyverno_helm_addon]
}

module "kyverno_policy_reporter_helm_addon" {
  count             = var.enable_kyverno_policy_reporter ? 1 : 0
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.kyverno_policy_reporter_helm_config
  irsa_config       = null
  addon_context     = var.addon_context
  depends_on        = [module.kyverno_helm_addon]
}
