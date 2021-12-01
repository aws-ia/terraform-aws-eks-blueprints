data "aws_region" "current" {}

locals {
  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region   = data.aws_region.current.name,
    cluster_name = var.eks_cluster_id
  })]

  default_cluster_autoscaler_helm_app = {
    name                       = "cluster-autoscaler"
    chart                      = "cluster-autoscaler"
    repository                 = "https://kubernetes.github.io/autoscaler"
    version                    = "9.10.8"
    namespace                  = "kube-system"
    timeout                    = "1200"
    create_namespace           = false
    values                     = local.default_helm_values
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
    description                = "Cluster AutoScaler helm Chart deployment configuration"
    postrender                 = ""
    set                        = []
    set_sensitive              = null
  }

  cluster_autoscaler_helm_app = merge(
    local.default_cluster_autoscaler_helm_app,
    var.cluster_autoscaler_helm_chart
  )

  argocd_gitops_config = {
    enable = true
  }
}
