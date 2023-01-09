locals {
  name            = "cert-manager"
  service_account = "cert-manager" # AWS PrivateCA is expecting the service account name as `cert-manager`

  # https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/Chart.template.yaml
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://charts.jetstack.io"
    version     = "v1.10.0"
    namespace   = local.name
    description = "Cert Manager Add-on"
    values      = local.default_helm_values
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = concat(
    [
      {
        name  = "serviceAccount.name"
        value = local.service_account
      },
      {
        name  = "serviceAccount.create"
        value = false
      }
    ],
    try(var.helm_config.set_values, [])
  )

  irsa_config = {
    kubernetes_namespace                = local.helm_config["namespace"]
    kubernetes_service_account          = local.service_account
    create_kubernetes_namespace         = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(local.helm_config["create_service_account_secret_token"], false)
    kubernetes_svc_image_pull_secrets   = var.kubernetes_svc_image_pull_secrets
    irsa_iam_policies                   = concat([aws_iam_policy.cert_manager.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account
  }
}
