locals {
  name            = try(var.helm_config.name, "cluster-autoscaler")
  namespace       = try(var.helm_config.namespace, "kube-system")
  service_account = try(var.helm_config.service_account, "${local.name}-sa")
}

module "helm_addon" {
  source = "../helm-addon"

  manage_via_gitops = var.manage_via_gitops

  # https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/Chart.yaml
  helm_config = merge({
    name        = local.name
    chart       = local.name
    version     = "9.21.0"
    repository  = "https://kubernetes.github.io/autoscaler"
    namespace   = local.namespace
    description = "Cluster AutoScaler helm Chart deployment configuration."
    values = [templatefile("${path.module}/values.yaml", {
      aws_region     = var.addon_context.aws_region_name
      eks_cluster_id = var.addon_context.eks_cluster_id
      image_tag      = "v${var.eks_cluster_version}.0"
    })]
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "rbac.serviceAccount.create"
      value = "false"
    },
    {
      name  = "rbac.serviceAccount.name"
      value = local.service_account
    }
  ]

  irsa_config = {
    create_kubernetes_namespace         = try(var.helm_config.create_namespace, false)
    kubernetes_namespace                = local.namespace
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(var.helm_config["create_service_account_secret_token"], false)
    kubernetes_service_account          = local.service_account
    irsa_iam_policies                   = [aws_iam_policy.cluster_autoscaler.arn]
  }

  addon_context = var.addon_context
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${var.addon_context.eks_cluster_id}-${local.name}-irsa"
  description = "Cluster Autoscaler IAM policy"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json

  tags = var.addon_context.tags
}
