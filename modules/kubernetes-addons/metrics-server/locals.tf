
locals {
  default_helm_config = {
    name                       = "metrics-server"
    chart                      = "metrics-server"
    repository                 = "https://kubernetes-sigs.github.io/metrics-server/"
    version                    = "3.7.0"
    namespace                  = "kube-system"
    timeout                    = "1200"
    create_namespace           = false
    set                        = []
    set_sensitive              = null
    lint                       = false
    values                     = null
    wait                       = true
    wait_for_jobs              = false
    description                = "Metric server helm Chart deployment configuration"
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
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
