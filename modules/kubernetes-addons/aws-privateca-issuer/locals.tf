locals {
  name                 = "aws-privateca-issuer"
  service_account_name = "${local.name}-sa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://cert-manager.github.io/aws-privateca-issuer"
    version     = "1.2.2"
    namespace   = local.name
    description = "AWS PCA Issuer helm Chart deployment configuration."
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = local.service_account_name
    }
  ]

  irsa_config = {
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    kubernetes_namespace              = local.helm_config["namespace"]
    create_kubernetes_service_account = true
    kubernetes_service_account        = local.service_account_name
    irsa_iam_policies                 = concat([aws_iam_policy.aws_privateca_issuer.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
