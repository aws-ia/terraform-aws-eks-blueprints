
locals {
  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  default_cert_manager_helm_app = {
    name                       = "cert-manager"
    chart                      = "cert-manager"
    repository                 = "https://charts.jetstack.io"
    version                    = "v1.6.1"
    namespace                  = "kube-system"
    timeout                    = "600"
    create_namespace           = false
    set                        = []
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

    # Install a CA issuer with a helper chart
    # See ./cert-manager-ca/templates/ca.yaml
    install_default_ca = var.manage_via_gitops ? false : true
  }

  cert_manager_helm_app = merge(
    local.default_cert_manager_helm_app,
    var.cert_manager_helm_chart
  )

  argocd_gitops_config = {
    enable = true
  }
}
