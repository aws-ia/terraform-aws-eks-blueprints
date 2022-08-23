module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  irsa_config       = null
  addon_context     = var.addon_context
}

resource "kubernetes_secret_v1" "datadog_api_key" {
  count = var.datadog_api_key != "" ? 1 : 0

  metadata {
    name      = "datadog-secret"
    namespace = local.helm_config["namespace"]
  }
  data = {
    # This will reveal a secret in the Terraform state
    api-key = var.datadog_api_key
  }

  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "datadog_agent" {
  yaml_body = yamlencode(local.datadog_agent)

  depends_on = [module.helm_addon, kubernetes_secret_v1.datadog_api_key]
}
