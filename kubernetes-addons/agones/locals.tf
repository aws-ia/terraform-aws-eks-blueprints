data "aws_region" "current" {}

locals {
  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  default_agones_helm_app = {
    name                       = "agones"
    chart                      = "agones"
    repository                 = "https://agones.dev/chart/stable"
    version                    = "1.18.0"
    namespace                  = "agones-system"
    timeout                    = "1200"
    create_namespace           = true
    description                = "Agones Gaming Server Helm Chart deployment configuration"
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
    gameserver_minport         = 7000
    gameserver_maxport         = 8000
  }

  agones_helm_app = merge(
    local.default_agones_helm_app,
    var.agones_helm_chart
  )

  argocd_gitops_config = {
    enable = true
  }
}
