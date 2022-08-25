locals {
  name                 = "external-secrets"
  service_account_name = "${local.name}-sa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://charts.external-secrets.io/"
    version     = "0.5.9"
    namespace   = local.name
    description = "The External Secrets Operator Helm chart default configuration"
    values      = null
    timeout     = "1200"
  }

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
    },
    {
      name  = "webhook.serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "webhook.serviceAccount.create"
      value = false
    },
    {
      name  = "certController.serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "certController.serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.external_secrets.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
