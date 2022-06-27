data "aws_region" "current" {}

locals {
  namespace       = try(var.helm_config.namespace, "velero")
  service_account = try(var.helm_config.service_account, "velero")
}

resource "aws_s3_bucket" "velero_bucket" {
  count = var.create_bucket == true ? 1 : 0

  bucket = var.bucket_name
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero
  helm_config = merge(
    {
      name        = "velero"
      description = "A Helm chart for velero"
      chart       = "velero"
      version     = "2.30.0"
      repository  = "https://vmware-tanzu.github.io/helm-charts/"
      namespace   = local.namespace
      values = [templatefile("${path.module}/values.yaml", {
        bucket = var.bucket_name,
        region = data.aws_region.current.name
      })]
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.server.name"
      value = local.service_account
    },
    {
      name  = "serviceAccount.server.create"
      value = false
    }
  ]

  irsa_config = {
    create_kubernetes_namespace = try(var.helm_config.create_namespace, true)
    kubernetes_namespace        = local.namespace

    create_kubernetes_service_account = true
    kubernetes_service_account        = local.service_account

    irsa_iam_policies = concat([aws_iam_policy.velero.arn], var.irsa_policies)
  }

  addon_context = var.addon_context
}

# https://github.com/vmware-tanzu/velero-plugin-for-aws#option-1-set-permissions-with-an-iam-user
data "aws_iam_policy_document" "velero" {
  statement {
    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]
    resources = [var.create_bucket == true ? "${aws_s3_bucket.velero_bucket[0].arn}/*" : "arn:${var.addon_context.aws_partition_id}:s3:::${var.bucket_name}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [var.create_bucket == true ? aws_s3_bucket.velero_bucket[0].arn : "arn:${var.addon_context.aws_partition_id}:s3:::${var.bucket_name}"]
  }
}

resource "aws_iam_policy" "velero" {
  name        = "${var.addon_context.eks_cluster_id}-velero"
  description = "Provides Velero permissions to backup and restore cluster resources"
  policy      = data.aws_iam_policy_document.velero.json

  tags = var.addon_context.tags
}
