locals {
  name            = "aws-for-fluent-bit"
  log_group_name  = var.cw_log_group_name == null ? "/${var.addon_context.eks_cluster_id}/worker-fluentbit-logs" : var.cw_log_group_name
  service_account = try(var.helm_config.service_account, "${local.name}-sa")

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  # https://github.com/aws/eks-charts/blob/master/stable/aws-for-fluent-bit/Chart.yaml
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://aws.github.io/eks-charts"
    version     = "0.1.24"
    namespace   = local.name
    values      = local.default_helm_values
    description = "aws-for-fluentbit Helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region      = var.addon_context.aws_region_name,
    log_group_name  = local.log_group_name,
    service_account = local.service_account
  })]

  argocd_gitops_config = {
    enable             = true
    logGroupName       = local.log_group_name
    serviceAccountName = local.service_account
  }

  irsa_config = {
    kubernetes_namespace                = local.helm_config["namespace"]
    kubernetes_service_account          = local.service_account
    create_kubernetes_namespace         = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(local.helm_config["create_service_account_secret_token"], false)
    irsa_iam_policies                   = concat([aws_iam_policy.aws_for_fluent_bit.arn], var.irsa_policies)
  }
}
