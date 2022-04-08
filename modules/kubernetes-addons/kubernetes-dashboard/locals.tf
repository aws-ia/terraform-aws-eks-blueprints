locals {
  name                 = "kubernetes-dashboard"
  service_account_name = "eks-admin"
  namespace            = "kube-system"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes.github.io/dashboard/"
    version     = "5.2.0"
    namespace   = local.namespace
    description = "Kubernetes Dashboard Helm Chart"
    values      = local.default_helm_values
    timeout     = "1200"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = []

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
    create_kubernetes_namespace       = false
    create_kubernetes_service_account = true
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
