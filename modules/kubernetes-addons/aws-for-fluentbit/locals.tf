locals {
  name                 = "aws-for-fluent-bit"
  log_group_name       = var.cw_log_group_name == null ? "/${var.addon_context.eks_cluster_id}/worker-fluentbit-logs" : var.cw_log_group_name
  service_account_name = "${local.name}-sa"

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

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://aws.github.io/eks-charts"
    version     = "0.1.18"
    namespace   = local.name
    values      = local.default_helm_values
    description = "aws-for-fluentbit Helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region           = var.addon_context.aws_region_name,
    log_group_name       = aws_cloudwatch_log_group.aws_for_fluent_bit.name,
    service_account_name = local.service_account_name
  })]

  argocd_gitops_config = {
    enable             = true
    logGroupName       = aws_cloudwatch_log_group.aws_for_fluent_bit.name
    serviceAccountName = local.service_account_name
  }

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.aws_for_fluent_bit.arn], var.irsa_policies)
  }
}
