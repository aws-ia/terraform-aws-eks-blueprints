module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "kubectl_manifest" "sa_config" {
  yaml_body = templatefile("${path.module}/manifests/eks-admin-service-account.yaml", {
    sa-name   = local.service_account_name
    namespace = local.helm_config["namespace"]
  })

  depends_on = [module.helm_addon]
}
