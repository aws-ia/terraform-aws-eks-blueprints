locals {
  name                 = "aws-fsx-csi-driver"
  service_account_name = "fsx-csi-sa"
  namespace            = "kube-system"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes-sigs.github.io/aws-fsx-csi-driver/"
    version     = "1.4.2"
    namespace   = local.namespace
    values      = []
    description = "The Amazon FSx for Lustre CSI driver Helm chart deployment configuration"
  }

  helm_config = merge(local.default_helm_config, var.helm_config)

  set_values = [
    {
      name  = "controller.serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "controller.serviceAccount.create"
      value = false
    },
    {
      name  = "node.serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "node.serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.aws_fsx_csi_driver.arn], var.irsa_policies)
    tags                              = var.addon_context.tags
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
