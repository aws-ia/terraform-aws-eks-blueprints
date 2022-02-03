locals {
  name                 = "crossplane-system"
  service_account_name = "crossplane"
  default_helm_config = {
    name        = "crossplane"
    chart       = "crossplane"
    repository  = "https://charts.crossplane.io/stable/"
    version     = "1.6.2"
    namespace   = local.name
    description = "Crossplane Helm chart"
    values      = local.default_helm_values
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    sa-name          = local.service_account_name
    operating-system = "linux"
  })]

  irsa_config = {
    kubernetes_namespace              = local.name
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = false
    iam_role_path                     = "/"
    tags                              = var.tags
    eks_cluster_id                    = var.eks_cluster_id
    irsa_iam_policies                 = var.irsa_policies
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
