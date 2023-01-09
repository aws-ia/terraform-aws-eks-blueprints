locals {
  name      = try(var.helm_config.name, "csi-secrets-store-provider-aws")
  namespace = try(var.helm_config.namespace, "kube-system")
}

resource "kubernetes_namespace_v1" "csi_secrets_store_provider_aws" {
  metadata {
    name = local.namespace
  }
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/aws/eks-charts/blob/master/stable/csi-secrets-store-provider-aws/Chart.yaml
  helm_config = merge(
    {
      name        = local.name
      chart       = local.name
      repository  = "https://aws.github.io/eks-charts"
      version     = "0.0.3"
      namespace   = kubernetes_namespace_v1.csi_secrets_store_provider_aws.metadata[0].name
      description = "A Helm chart to install the Secrets Store CSI Driver and the AWS Key Management Service Provider inside a Kubernetes cluster."
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
