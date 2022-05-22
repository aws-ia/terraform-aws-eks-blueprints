locals {
  name = "velero"

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.name
  }
}

module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge({
    name        = local.name
    description = "A Helm chart for velero"
    chart       = local.name
    version     = "2.29.6"
    repository  = "https://vmware-tanzu.github.io/helm-charts/"
    namespace   = local.name
    values = [
      <<-EOT
      configuration:
        provider: aws
        backupStorageLocation:
          bucket: ${var.backup_s3_bucket}

      initContainers:
        - name: velero-plugin-for-aws
          image: velero/velero-plugin-for-aws:v1.4.1
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - mountPath: /target
              name: plugins
      EOT
    ]
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
    kubernetes_namespace              = local.name
    kubernetes_service_account        = local.name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    iam_role_path                     = "/"
    tags                              = var.addon_context.tags
    eks_cluster_id                    = var.addon_context.eks_cluster_id
    irsa_iam_policies                 = concat([aws_iam_policy.velero.arn], var.irsa_policies)
  }

  # Blueprints
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

    resources = ["arn:aws:s3:::${var.backup_s3_bucket}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.backup_s3_bucket}"]
  }
}

resource "aws_iam_policy" "velero" {
  name        = "${var.addon_context.eks_cluster_id}-velero"
  description = "Provides Velero permissions to backup and restore cluster resources"
  policy      = data.aws_iam_policy_document.velero.json

  tags = var.addon_context.tags
}
