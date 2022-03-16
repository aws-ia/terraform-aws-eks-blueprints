locals {
  name = "prometheus"
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://prometheus-community.github.io/helm-charts"
    version     = "15.3.0"
    namespace   = local.name
    timeout     = "1200"
    description = "Prometheus helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    operating_system = "linux",
  })]

  amazon_prometheus_workspace_url          = var.amazon_prometheus_workspace_endpoint != null ? "${var.amazon_prometheus_workspace_endpoint}api/v1/remote_write" : ""
  amazon_prometheus_ingest_iam_role_arn    = var.enable_amazon_prometheus ? module.irsa_amp_ingest[0].irsa_iam_role_arn : ""
  amazon_prometheus_ingest_service_account = "amp-ingest"

  amp_config_values = var.enable_amazon_prometheus ? [
    {
      name  = "serviceAccounts.server.name"
      value = local.amazon_prometheus_ingest_service_account
    },
    {
      name  = "serviceAccounts.server.create"
      value = false
    },
    {
      name  = "serviceAccounts.server.annotations.eks\\.amazonaws\\.com/role-arn"
      value = local.amazon_prometheus_ingest_iam_role_arn
    },
    {
      name  = "server.remoteWrite[0].url"
      value = local.amazon_prometheus_workspace_url
    },
    {
      name  = "server.remoteWrite[0].sigv4.region"
      value = var.addon_context.aws_region_name
    }
  ] : []

  irsa_config = {
    kubernetes_namespace          = local.helm_config["namespace"]
    create_kubernetes_namespace   = true
    kubernetes_service_account    = var.enable_amazon_prometheus ? local.amazon_prometheus_ingest_service_account : null
    iam_role_path                 = var.enable_amazon_prometheus ? var.irsa_role_path : null
    irsa_iam_policies             = var.enable_amazon_prometheus ? [aws_iam_policy.ingest[0].arn] : null
    irsa_iam_permissions_boundary = var.enable_amazon_prometheus ? var.irsa_permissions_boundary : null
    addon_context                 = var.addon_context
  }

  amp_gitops_config = var.enable_amazon_prometheus ? {
    roleArn            = local.amazon_prometheus_ingest_iam_role_arn
    ampWorkspaceUrl    = local.amazon_prometheus_workspace_url
    serviceAccountName = local.amazon_prometheus_ingest_service_account
  } : {}

  argocd_gitops_config = merge(
    { enable = true },
    local.amp_gitops_config
  )
}
