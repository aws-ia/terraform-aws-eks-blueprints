locals {
  name            = try(var.helm_config.name, "cluster-autoscaler")
  namespace       = try(var.helm_config.namespace, "kube-system")
  service_account = "${local.name}-sa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    version     = "9.20.0"
    repository  = "https://kubernetes.github.io/autoscaler"
    namespace   = local.namespace
    description = "Cluster AutoScaler helm Chart deployment configuration."
    values      = local.default_helm_values
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region     = var.addon_context.aws_region_name
    eks_cluster_id = var.addon_context.eks_cluster_id
    image_tag      = "v${var.eks_cluster_version}.0"
  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = concat(
    [
      {
        name  = "rbac.serviceAccount.name"
        value = local.service_account
      },
      {
        name  = "rbac.serviceAccount.create"
        value = false
      }
    ],
    try(var.helm_config.set_values, [])
  )

  irsa_config = {
    create_kubernetes_namespace       = try(var.helm_config.create_namespace, false)
    kubernetes_namespace              = local.namespace
    create_kubernetes_service_account = true
    kubernetes_service_account        = local.service_account
    irsa_iam_policies                 = [aws_iam_policy.cluster_autoscaler.arn]
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account
  }
}
