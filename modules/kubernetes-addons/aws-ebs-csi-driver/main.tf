locals {
  create_irsa = try(var.addon_config.service_account_role_arn == "", true)
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = try(var.addon_config.addon_version, null)
  resolve_conflicts        = try(var.addon_config.resolve_conflicts, null)
  service_account_role_arn = local.create_irsa ? module.irsa_addon[0].irsa_iam_role_arn : try(var.addon_config.service_account_role_arn, null)
  preserve                 = try(var.addon_config.preserve, true)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}

module "irsa_addon" {
  source = "../../../modules/irsa"

  count = local.create_irsa ? 1 : 0

  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = "kube-system"
  kubernetes_service_account        = "ebs-csi-controller-sa"
  irsa_iam_policies                 = concat([aws_iam_policy.aws_ebs_csi_driver[0].arn], try(var.addon_config.additional_iam_policies, []))
  addon_context                     = var.addon_context
}

resource "aws_iam_policy" "aws_ebs_csi_driver" {
  count = local.create_irsa ? 1 : 0

  name        = "${var.addon_context.eks_cluster_id}-aws-ebs-csi-driver-irsa"
  description = "IAM Policy for AWS EBS CSI Driver"
  path        = try(var.addon_context.irsa_iam_role_path, null)
  policy      = data.aws_iam_policy_document.aws_ebs_csi_driver[0].json

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}

data "aws_iam_policy_document" "aws_ebs_csi_driver" {
  count = local.create_irsa ? 1 : 0

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:AttachVolume",
      "ec2:CreateSnapshot",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:${var.addon_context.aws_partition_id}:ec2:*:*:volume/*",
      "arn:${var.addon_context.aws_partition_id}:ec2:*:*:snapshot/*",
    ]

    actions = ["ec2:CreateTags"]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"

      values = [
        "CreateVolume",
        "CreateSnapshot",
      ]
    }
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:${var.addon_context.aws_partition_id}:ec2:*:*:volume/*",
      "arn:${var.addon_context.aws_partition_id}:ec2:*:*:snapshot/*",
    ]

    actions = ["ec2:DeleteTags"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:CreateVolume"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:CreateVolume"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/CSIVolumeName"
      values   = ["*"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:CreateVolume"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/kubernetes.io/cluster/*"
      values   = ["owned"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:DeleteVolume"]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:DeleteVolume"]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/CSIVolumeName"
      values   = ["*"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:DeleteVolume"]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/kubernetes.io/cluster/*"
      values   = ["owned"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:DeleteSnapshot"]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/CSIVolumeSnapshotName"
      values   = ["*"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:DeleteSnapshot"]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}
