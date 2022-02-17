locals {
  service_account_name = "efs-csi-sa"

  default_helm_config = {
    name                       = "aws-efs-csi-driver"
    chart                      = "aws-efs-csi-driver"
    repository                 = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
    version                    = "2.2.3"
    namespace                  = "kube-system"
    timeout                    = "1200"
    create_namespace           = false
    values                     = local.default_helm_values
    set                        = []
    set_sensitive              = null
    lint                       = true
    wait                       = true
    wait_for_jobs              = false
    description                = "aws-efs-csi-driver Helm Chart for the EFS CSI driver"
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

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    service_account_name = local.service_account_name,
  })]

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
