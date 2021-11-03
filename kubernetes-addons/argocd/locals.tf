
locals {
  default_argocd_helm_chart = {
    name             = "argo-cd"
    chart            = "argo-cd"
    repository       = "https://argoproj.github.io/argo-helm"
    version          = "3.26.3"
    namespace        = "argocd-infra"
    timeout          = "1200"
    create_namespace = true
    values           = local.default_argocd_helm_values
    set = [{
      name  = "nodeSelector.kubernetes\\.io/os"
      value = "linux"
    }]
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
    local.default_argocd_helm_chart,
    var.argocd_helm_chart
  )
  default_argocd_helm_values = [templatefile("${path.module}/argocd-values.yaml", {})]
}
