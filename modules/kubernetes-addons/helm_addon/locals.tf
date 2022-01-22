locals {
  service_account_name = "${var.name}-sa"
  namespace            = "${var.name}-ns"

  default_helm_config = {
    name                       = var.name
    chart                      = var.name
    namespace                  = local.namespace
    timeout                    = "1200"
    create_namespace           = true
    description                = "Kubernetes Helm AddOn"
    lint                       = false
    wait                       = true
    wait_for_jobs              = false
    verify                     = false
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
    set                        = []
    set_sensitive              = []
    values                     = []
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
