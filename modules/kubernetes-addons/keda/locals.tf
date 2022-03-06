locals {
  name                 = "keda"
  service_account_name = "keda-operator-sa"
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kedacore.github.io/charts"
    version     = "2.6.2"
    namespace   = local.name
    description = "Keda Event-based autoscaler for workloads on Kubernetes"
    values      = local.default_helm_values
    timeout     = "1200"
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
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.keda_irsa.arn], var.irsa_policies)
    irsa_iam_permissions_boundary     = var.irsa_permissions_boundary
    eks_cluster_id                    = var.addon_context.eks_cluster_id
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
