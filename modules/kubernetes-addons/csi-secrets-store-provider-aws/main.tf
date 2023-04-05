locals {
  name      = try(var.helm_config.name, "secrets-store-csi-driver-provider-aws")
  namespace = try(var.helm_config.namespace, "kube-system")
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/aws/secrets-store-csi-driver-provider-aws/blob/main/charts/secrets-store-csi-driver-provider-aws/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
      version          = "0.3.2"
      namespace        = local.namespace
      create_namespace = local.namespace == "kube-system" ? false : true
      description      = "A Helm chart for the AWS Secrets Manager and Config Provider for Secret Store CSI Driver."
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
