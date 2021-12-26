data "aws_region" "current" {}

locals {

  amp_workspace_url = "https://aps-workspaces.${data.aws_region.current.id}.amazonaws.com/workspaces/${var.amazon_prometheus_workspace_id}/api/v1/remote_write"

  amp_config_values = var.enable_amazon_prometheus ? [{
    name  = "serviceAccounts.server.name"
    value = var.amazon_prometheus_ingest_service_account
    },
    {
      name  = "serviceAccounts.server.annotations.eks\\.amazonaws\\.com/role-arn"
      value = var.amazon_prometheus_ingest_iam_role_arn
    },
    {
      name  = "server.remoteWrite[0].url"
      value = local.amp_workspace_url
    },
    {
      name  = "server.remoteWrite[0].sigv4.region"
      value = data.aws_region.current.id
  }] : []

  default_helm_config = {
    name                       = "prometheus"
    chart                      = "prometheus"
    repository                 = "https://prometheus-community.github.io/helm-charts"
    version                    = "14.4.0"
    namespace                  = "prometheus"
    timeout                    = "1200"
    create_namespace           = true
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

  argocd_gitops_config = {
    enable             = true
    ampWorkspaceUrl    = local.amp_workspace_url
    roleArn            = var.amazon_prometheus_ingest_iam_role_arn
    serviceAccountName = var.amazon_prometheus_ingest_service_account
  }
}
