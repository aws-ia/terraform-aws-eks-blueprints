module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/aws/eks-charts/blob/master/stable/csi-secrets-store-provider-aws/Chart.yaml

  helm_config = local.helm_config

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context

  depends_on = [kubernetes_namespace_v1.csi_secrets_store_provider_aws]
}

resource "kubernetes_namespace_v1" "csi_secrets_store_provider_aws" {
  count = try(local.helm_config["create_namespace"], true) && local.helm_config["namespace"] != "kube-system" ? 1 : 0
  metadata {
    name = local.helm_config["namespace"]
  }
}
