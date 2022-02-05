locals {
  name                 = "argo-rollouts"
  service_account_name = "${local.name}-sa"
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://argoproj.github.io/argo-helm"
    version     = "2.9.1"
    namespace   = local.name
    description = "Argo Rollouts AddOn Helm Chart"
    values      = local.default_helm_values
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    sa-name = local.service_account_name
  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    kubernetes_namespace              = local.name
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    iam_role_path                     = "/"
    tags                              = var.tags
    eks_cluster_id                    = var.eks_cluster_id
    irsa_iam_policies                 = []
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
