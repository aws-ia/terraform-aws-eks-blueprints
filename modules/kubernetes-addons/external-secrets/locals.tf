locals {
  name            = "external-secrets"
  service_account = try(var.helm_config.service_account, "${local.name}-sa")

  # https://github.com/external-secrets/external-secrets/blob/main/deploy/charts/external-secrets/Chart.yaml
  helm_config = merge(
    {
      name        = local.name
      chart       = local.name
      repository  = "https://charts.external-secrets.io/"
      version     = "0.6.0"
      namespace   = local.name
      description = "The External Secrets Operator Helm chart default configuration"
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account
    },
    {
      name  = "serviceAccount.create"
      value = false
    },
    {
      name  = "webhook.serviceAccount.name"
      value = local.service_account
    },
    {
      name  = "webhook.serviceAccount.create"
      value = false
    },
    {
      name  = "certController.serviceAccount.name"
      value = local.service_account
    },
    {
      name  = "certController.serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    kubernetes_namespace                = local.helm_config["namespace"]
    kubernetes_service_account          = local.service_account
    create_kubernetes_namespace         = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(local.helm_config["create_service_account_secret_token"], false)
    irsa_iam_policies                   = concat([aws_iam_policy.external_secrets.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account
  }
}
