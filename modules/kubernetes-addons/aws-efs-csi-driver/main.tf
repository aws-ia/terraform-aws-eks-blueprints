locals {
  name                 = try(var.helm_config.name, "aws-efs-csi-driver")
  namespace            = try(var.helm_config.namespace, "kube-system")
  service_account_name = "${local.name}-sa"
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
    kubernetes_namespace              = local.namespace
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = try(var.helm_config.create_namespace, false)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.aws_efs_csi_driver.arn], var.irsa_policies)
  }

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

  addon_context = var.addon_context
}

data "aws_iam_policy_document" "aws_efs_csi_driver" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeAvailabilityZones",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["elasticfilesystem:CreateAccessPoint"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["elasticfilesystem:DeleteAccessPoint"]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount",
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "elasticfilesystem:AccessedViaMountTarget"
      values   = ["true"]
    }
  }
}


resource "aws_iam_policy" "aws_efs_csi_driver" {
  name        = "${var.addon_context.eks_cluster_id}-efs-csi-policy"
  description = "IAM Policy for AWS EFS CSI Driver"
  policy      = data.aws_iam_policy_document.aws_efs_csi_driver.json
  tags        = var.addon_context.tags
}
