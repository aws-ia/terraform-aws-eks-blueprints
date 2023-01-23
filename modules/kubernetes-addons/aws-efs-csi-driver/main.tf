locals {
  name            = try(var.helm_config.name, "aws-efs-csi-driver")
  namespace       = try(var.helm_config.namespace, "kube-system")
  service_account = try(var.helm_config.service_account, "${local.name}-sa")
}

module "helm_addon" {
  source = "../helm-addon"

  manage_via_gitops = var.manage_via_gitops

  # https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/charts/aws-efs-csi-driver/Chart.yaml
  helm_config = merge({
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
    version     = "2.3.2"
    namespace   = local.namespace
    description = "The AWS EFS CSI driver Helm chart deployment configuration"
    },
    var.helm_config
  )

  irsa_config = {
    kubernetes_namespace                = local.namespace
    kubernetes_service_account          = local.service_account
    create_kubernetes_namespace         = try(var.helm_config.create_namespace, false)
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(var.helm_config["create_service_account_secret_token"], false)
    irsa_iam_policies                   = concat([aws_iam_policy.aws_efs_csi_driver.arn], var.irsa_policies)
  }

  set_values = [
    {
      name  = "controller.serviceAccount.name"
      value = local.service_account
    },
    {
      name  = "controller.serviceAccount.create"
      value = false
    },
    {
      name  = "node.serviceAccount.name"
      value = local.service_account
    },
    {
      name  = "node.serviceAccount.create"
      value = false
    }
  ]

  addon_context = var.addon_context
}

resource "aws_iam_policy" "aws_efs_csi_driver" {
  name        = "${var.addon_context.eks_cluster_id}-efs-csi-policy"
  description = "IAM Policy for AWS EFS CSI Driver"
  policy      = data.aws_iam_policy_document.aws_efs_csi_driver.json
  tags        = var.addon_context.tags
}
