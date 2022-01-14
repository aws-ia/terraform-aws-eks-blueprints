locals {
  service_account_name = "cluster-autoscaler-sa"
  namespace            = "kube-system"

  default_helm_config = {
    name                       = "cluster-autoscaler"
    chart                      = "cluster-autoscaler"
    repository                 = "https://kubernetes.github.io/autoscaler"
    version                    = "9.10.8"
    namespace                  = local.namespace
    timeout                    = "300"
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
    set                        = null
    set_sensitive              = null
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  ca_set_values = [
    {
      name  = "rbac.serviceAccount.create"
      value = "false"
    },
    {
      name  = "rbac.serviceAccount.name"
      value = local.service_account_name
    }
  ]

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region           = data.aws_region.current.name,
    eks_cluster_id       = var.eks_cluster_id
    service_account_name = local.service_account_name
  })]

  argocd_gitops_config = {
    enable             = true
    clusterName        = var.eks_cluster_id
    serviceAccountName = local.service_account_name
  }
}
