
locals {
  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  default_nginx_helm_app = {
    name                       = "ingress-nginx"
    chart                      = "ingress-nginx"
    repository                 = "https://kubernetes.github.io/ingress-nginx"
    version                    = "4.0.6"
    namespace                  = "kube-system"
    timeout                    = "1200"
    create_namespace           = false
    values                     = local.default_helm_values
    set                        = []
    set_sensitive              = null
    lint                       = false
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
    wait                       = true
    wait_for_jobs              = false
    dependency_update          = false
    replace                    = false
    description                = "The NGINX HelmChart Ingress Controller deployment configuration"
    postrender                 = ""
  }

  nginx_helm_app = merge(
    local.default_nginx_helm_app,
    var.nginx_helm_chart
  )

  argocd_gitops_config = {
    enable = true
  }
}
