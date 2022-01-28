module "helm_addon" {
  source            = "../helm_addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
}