data "aws_region" "current" {}

locals {
  name      = "velero"
  namespace = try(var.helm_config.namespace, local.name)

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.name
  }
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero
  helm_config = merge({
    name        = local.name
    description = "A Helm chart for velero"
    chart       = local.name
    version     = "2.30.0"
    repository  = "https://vmware-tanzu.github.io/helm-charts/"
    namespace   = local.namespace
    values = [templatefile("${path.module}/values.yaml", {
      bucket = var.backup_s3_bucket,
      region = data.aws_region.current.name
    })]
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.server.name"
      value = local.name
    },
    {
      name  = "serviceAccount.server.create"
      value = false
    }
  ]

  irsa_config = {
    create_kubernetes_namespace = true
    kubernetes_namespace        = local.namespace

    create_kubernetes_service_account = true
    kubernetes_service_account        = try(var.helm_config.namespace, local.name)

    irsa_iam_policies = concat([aws_iam_policy.velero.arn], var.irsa_policies)
  }

  # Blueprints
  addon_context = var.addon_context
}

# https://github.com/vmware-tanzu/velero-plugin-for-aws#option-1-set-permissions-with-an-iam-user
data "aws_iam_policy_document" "velero" {
  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot",
      "ec2:DescribeSnapshots",
      "ec2:DescribeVolumes",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["arn:${var.addon_context.aws_partition_id}:s3:::${var.backup_s3_bucket}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:${var.addon_context.aws_partition_id}:s3:::${var.backup_s3_bucket}"]
  }
}

resource "aws_iam_policy" "velero" {
  name        = "${var.addon_context.eks_cluster_id}-velero"
  description = "Provides Velero permissions to backup and restore cluster resources"
  policy      = data.aws_iam_policy_document.velero.json

  tags = var.addon_context.tags
}
