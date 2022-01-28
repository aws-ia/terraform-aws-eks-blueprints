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
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }

  irsa_config = {
    eks_cluster_id                    = var.eks_cluster_id
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    kubernetes_namespace              = local.name
    kubernetes_service_account        = local.service_account_name
    tags                              = var.tags
  }
}