locals {
  name            = try(var.helm_config.name, "thanos")
  namespace       = try(var.helm_config.namespace, local.name)
  service_account = try(var.helm_config.service_account, local.name)
  helm_config = merge(
    {
      name        = local.name
      chart       = local.name
      repository  = "https://charts.bitnami.com/bitnami"
      version     = "11.6.4"
      namespace   = local.namespace
      description = "thanos helm Chart deployment configuration"
    },
    var.helm_config
  )
  set_values = [{
    name  = "serviceAccount.name"
    value = local.service_account
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]
  irsa_config = {
    kubernetes_namespace              = local.namespace
    kubernetes_service_account        = local.service_account
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = var.irsa_policies
  }
}
