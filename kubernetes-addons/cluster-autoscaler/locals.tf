
locals {
  default_cluster_autoscaler_helm_app = {
    name                       = "cluster-autoscaler"
    chart                      = "cluster-autoscaler"
    repository                 = "https://kubernetes.github.io/autoscaler"
    version                    = "9.10.7"
    namespace                  = "kube-system"
    timeout                    = "1200"
    create_namespace           = false
    values                     = null
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
    set = [{
      name  = "autoDiscovery.clusterName"
      value = var.eks_cluster_id
    }]
    set_sensitive = null
  }
  cluster_autoscaler_helm_app = merge(
    local.default_cluster_autoscaler_helm_app,
    var.cluster_autoscaler_helm_chart
  )
}
