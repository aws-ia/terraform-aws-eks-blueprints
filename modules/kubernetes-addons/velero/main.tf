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

  # https://github.com/vmware-tanzu/helm-charts/blob/main/charts/velero/Chart.yaml
  helm_config = merge({
    name        = local.name
    description = "A Helm chart for velero"
    chart       = local.name
    version     = "3.1.0"
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
    create_kubernetes_namespace = try(var.helm_config["create_namespace"], true)
    kubernetes_namespace        = local.namespace

    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(var.helm_config["create_service_account_secret_token"], false)
    kubernetes_service_account          = try(var.helm_config.service_account, local.name)

    irsa_iam_policies = concat([aws_iam_policy.velero.arn], var.irsa_policies)
  }

  # Blueprints
  addon_context = var.addon_context
}

resource "aws_iam_policy" "velero" {
  name        = "${var.addon_context.eks_cluster_id}-velero"
  description = "Provides Velero permissions to backup and restore cluster resources"
  policy      = data.aws_iam_policy_document.velero.json

  tags = var.addon_context.tags
}
