locals {
  name      = try(var.helm_config.name, "secrets-store-csi-driver-provider-aws")
  namespace = try(var.helm_config.namespace, local.name)
}

resource "kubernetes_namespace_v1" "csi_secrets_store_provider_aws" {
  count = try(var.helm_config["create_namespace"], true) && local.namespace != "kube-system" ? 1 : 0
  metadata {
    name = local.namespace
  }
}

module "helm_addon" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints/modules/kubernetes-addons/helm-addon"

  # https://github.com/aws/secrets-store-csi-driver-provider-aws/blob/main/charts/secrets-store-csi-driver-provider-aws/Chart.yaml
  helm_config = merge(
    {
      name        = local.name
      repository  = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
      chart       = "secrets-store-csi-driver-provider-aws"
      version     = "0.2.0"
      namespace   = local.namespace
      description = "A Helm chart for the AWS Secrets Manager and Config Provider for Secret Store CSI Driver"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
