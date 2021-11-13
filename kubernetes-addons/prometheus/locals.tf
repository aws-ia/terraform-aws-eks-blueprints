data "aws_region" "current" {}

locals {
	amp_workspace_url = "https://aps-workspaces.${data.aws_region.current.id}.amazonaws.com/workspaces/${var.amp_workspace_id}/api/v1/remote_write"

	default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region    				= data.aws_region.current.name,
		ingest_role_arn				= var.amp_ingest_role_arn
		service_account_name	= var.service_account_amp_ingest_name
		amp_workspace_url			= local.amp_workspace_url
	})]

  default_prometheus_helm_app = {
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
		set												 = []
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
  prometheus_helm_app = merge(
    local.default_prometheus_helm_app,
  	var.prometheus_helm_chart
	)
}
