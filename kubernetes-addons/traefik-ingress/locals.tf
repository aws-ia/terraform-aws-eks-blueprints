
locals {
  default_traefik_helm_app = {
    name             = "traefik"
    chart            = "traefik"
    repository       = "https://helm.traefik.io/traefik"
    version          = "10.0.0"
    namespace        = "kube-system"
    timeout          = "1200"
    create_namespace = false
    values           = null
    set              = null
    set_sensitive    = null
    lint             = false

    verify                     = false
    keyring                    = ""
    repository_key_file        = ""
    repository_cert_file       = ""
    repository_ca_file         = ""
    repository_username        = ""
    repository_password        = ""
    devel                      = ""
    disable_webhooks           = false
    reuse_values               = false
    reset_values               = false
    force_update               = false
    recreate_pods              = false # (Optional) Perform pods restart during upgrade/rollback
    cleanup_on_fail            = false # (Optional) Allow deletion of new resources created in this upgrade when upgrade fails
    max_history                = 0
    atomic                     = false
    skip_crds                  = false
    render_subchart_notes      = true
    disable_openapi_validation = false
    wait                       = true  # (Optional) Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as timeout
    wait_for_jobs              = false # (Optional) If wait is enabled, will wait until all Jobs have been completed before marking the release as successful. It will wait for as long as timeout
    dependency_update          = false
    replace                    = false
    description                = ""
    postrender                 = ""
  }
  traefik_helm_app = merge(
    local.default_traefik_helm_app,
    var.traefik_helm_chart
  )
}
