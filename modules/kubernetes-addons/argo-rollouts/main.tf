module "helm_addon" {
  source            = "../helm_addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
}