locals {
  name                 = "cluster-autoscaler"
  service_account_name = "${local.name}-sa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes.github.io/autoscaler"
    version     = "9.15.0"
    namespace   = "kube-system"
    description = "Cluster AutoScaler helm Chart deployment configuration."
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region     = var.addon_context.aws_region_name,
    eks_cluster_id = var.addon_context.eks_cluster_id
  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = [
    {
      name  = "rbac.serviceAccount.create"
      value = "false"
    },
    {
      name  = "rbac.serviceAccount.name"
      value = local.service_account_name
    }
  ]

  irsa_config = {
    create_kubernetes_namespace       = false
    kubernetes_namespace              = "kube-system"
    create_kubernetes_service_account = true
    kubernetes_service_account        = local.service_account_name
    irsa_iam_policies                 = [aws_iam_policy.cluster_autoscaler.arn]
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
