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
    kubernetes_namespace              = local.namespace
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = false
    create_kubernetes_service_account = true
    iam_role_path                     = "/"
    irsa_iam_policies                 = var.irsa_policies
    irsa_iam_permissions_boundary     = var.irsa_permissions_boundary
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
