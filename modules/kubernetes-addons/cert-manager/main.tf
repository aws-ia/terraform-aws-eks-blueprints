module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "helm_release" "cert_manager_ca" {
  count     = var.manage_via_gitops ? 0 : 1
  name      = "cert-manager-ca"
  chart     = "${path.module}/cert-manager-ca"
  version   = "0.2.0"
  namespace = local.helm_config["namespace"]

  depends_on = [module.helm_addon]
}
