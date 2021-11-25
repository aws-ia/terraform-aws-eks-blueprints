
locals {
  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  default_windows_vpc_controllers_helm_app = {
    name                       = "windows-vpc-controllers"
    chart                      = "windows-vpc-controllers"
    repository                 = "https://charts.jetstack.io"
    version                    = "v1.5.4"
    namespace                  = "kube-system"
    timeout                    = "600"
    create_namespace           = false
    set_sensitive              = null
    lint                       = false
    values                     = local.default_helm_values
    wait                       = true
    wait_for_jobs              = false
    description                = "Cert Manager Helm chart deployment configuration"
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

  windows_vpc_controllers_helm_app = merge(
    local.default_windows_vpc_controllers_helm_app,
    var.windows_vpc_controllers_helm_chart
  )

  argocd_gitops_config = {
    enable = true
  }
}
