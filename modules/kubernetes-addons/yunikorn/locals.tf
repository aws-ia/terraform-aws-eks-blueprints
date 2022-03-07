locals {
  name                 = "yunikorn"
  service_account_name = "yunikorn-admin"
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://apache.github.io/incubator-yunikorn-release"
    version     = "0.12.2"
    namespace   = local.name
    description = "Apache YuniKorn (Incubating) is a light-weight, universal resource scheduler for container orchestrator systems"
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

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    irsa_iam_policies                 = var.irsa_policies
    irsa_iam_permissions_boundary     = var.irsa_permissions_boundary
  }

  argocd_gitops_config = {
    enable                   = true
    serviceAccountName       = local.service_account_name
    embedAdmissionController = false
  }
}
