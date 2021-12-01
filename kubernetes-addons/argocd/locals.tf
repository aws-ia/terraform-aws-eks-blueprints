
locals {
  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  default_argocd_helm_app = {
    name                       = "argo-cd"
    chart                      = "argo-cd"
    repository                 = "https://argoproj.github.io/argo-helm"
    version                    = "3.26.8"
    namespace                  = "argocd"
    timeout                    = "1200"
    create_namespace           = true
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
    description                = "The argocd HelmChart Ingress Controller deployment configuration"
    postrender                 = ""
  }

  argocd_helm_app = merge(
    local.default_argocd_helm_app,
    var.argocd_helm_chart
  )

  # Global Application Values
  global_application_values = {
    region      = data.aws_region.current.id
    account     = data.aws_caller_identity.current.account_id
    clusterName = var.eks_cluster_name
  }
}
