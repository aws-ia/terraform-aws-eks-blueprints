locals {

  default_helm_config = {
    name                       = "prometheus"
    chart                      = "prometheus"
    repository                 = "https://prometheus-community.github.io/helm-charts"
    version                    = "14.4.0"
    namespace                  = "prometheus"
    timeout                    = "300"
    create_namespace           = false
    description                = "Prometheus helm Chart deployment configuration"
    lint                       = false
    values                     = local.default_helm_values
    wait                       = true
    wait_for_jobs              = false
    verify                     = false
    set                        = []
    set_sensitive              = null
    keyring                    = ""
    repository_key_file        = ""
    repository_cert_file       = ""
    repository_ca_file         = ""
    repository_username        = ""
    repository_password        = ""
    disable_webhooks           = false
    reuse_values               = false
    reset_values               = false
    force_update               = false
    recreate_pods              = false
    cleanup_on_fail            = false
    max_history                = 0
    atomic                     = false
    skip_crds                  = false
    render_subchart_notes      = true
    disable_openapi_validation = false
    dependency_update          = false
    replace                    = false
    postrender                 = ""
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    operating_system = "linux",
  })]

  amazon_prometheus_workspace_id = var.amazon_prometheus_workspace_id == null && var.enable_amp_for_prometheus ? aws_prometheus_workspace.amp_workspace[0].id : var.amazon_prometheus_workspace_id
  amp_workspace_url = var.enable_amp_for_prometheus && local.amazon_prometheus_workspace_id!= null ? "https://aps-workspaces.${data.aws_region.current.id}.amazonaws.com/workspaces/${local.amazon_prometheus_workspace_id}/api/v1/remote_write" : null
  amazon_prometheus_ingest_iam_role_arn = var.enable_amp_for_prometheus ? module.irsa.*.ingest.irsa_iam_role_arn[0] : null
  amazon_prometheus_ingest_service_account = local.irsa_config.ingest.service_account

  amp_config_values = var.enable_amp_for_prometheus ? [{
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
      value = local.amp_workspace_url
    },
    {
      name  = "server.remoteWrite[0].sigv4.region"
      value = data.aws_region.current.id
    }] : []

  irsa_config = {
    ingest = {
      service_account             = "amp-ingest",
      create_kubernetes_namespace = false,
      irsa_iam_policies           = var.enable_amp_for_prometheus ? [aws_iam_policy.ingest[0].arn]: []

    },
    query = {
      service_account             = "amp-query",
      create_kubernetes_namespace = false,
      irsa_iam_policies           = var.enable_amp_for_prometheus ? [aws_iam_policy.query[0].arn]: []
    }
  }

  argocd_gitops_config = {
    enable             = true
    ampWorkspaceUrl    = local.amp_workspace_url
    roleArn            = local.amazon_prometheus_ingest_iam_role_arn
    serviceAccountName = local.amazon_prometheus_ingest_service_account
  }
}
