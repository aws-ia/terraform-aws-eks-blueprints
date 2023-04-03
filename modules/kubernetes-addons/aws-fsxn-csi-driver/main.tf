#-------------------------------------------------
# FSx for NetApp ONTAP Helm Add-on
#-------------------------------------------------
module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}
