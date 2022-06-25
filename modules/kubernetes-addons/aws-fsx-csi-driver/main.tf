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
}

#-------------------------------------------------
# FSx for Lustre Helm Add-on
#-------------------------------------------------
module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

#-------------------------------------------------
# IRSA IAM policy for FSx for Lustre
#-------------------------------------------------
resource "aws_iam_policy" "aws_fsx_csi_driver" {
  name        = "${var.addon_context.eks_cluster_id}-fsx-csi-policy"
  description = "IAM Policy for AWS FSx CSI Driver"
  policy      = data.aws_iam_policy_document.aws_fsx_csi_driver.json
  tags        = var.addon_context.tags
}

data "aws_iam_policy_document" "aws_fsx_csi_driver" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:iam::*:role/aws-service-role/s3.data-source.lustre.fsx.amazonaws.com/*"]

    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["fsx.amazonaws.com"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:ListBucket",
      "fsx:CreateFileSystem",
      "fsx:DeleteFileSystem",
      "fsx:DescribeFileSystems",
      "fsx:TagResource",
    ]
  }
}
