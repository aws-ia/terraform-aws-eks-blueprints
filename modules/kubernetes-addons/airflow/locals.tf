locals {
  name = "airflow"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://airflow.apache.org"
    version     = "1.6.0"
    namespace   = local.name
    values      = []
    description = "The Amazon FSx for Lustre CSI driver Helm chart deployment configuration"
  }

  helm_config = merge(local.default_helm_config, var.helm_config)

  set_values = [
    {
      name  = "scheduler.serviceAccount.name"
      value = local.name
    },
    {
      name  = "scheduler.serviceAccount.create"
      value = false
    },
    {
      name  = "webserver.serviceAccount.name"
      value = local.name
    },
    {
      name  = "webserver.serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = var.irsa_policies
    tags                              = var.addon_context.tags
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.name
  }
}
