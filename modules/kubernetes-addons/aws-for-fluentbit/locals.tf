locals {
  log_group_name       = var.cw_log_group_name == null ? "/${var.addon_context.eks_cluster_id}/worker-fluentbit-logs" : var.cw_log_group_name
  service_account_name = "aws-for-fluent-bit-sa"

  override_set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  default_helm_config = {
    name                       = "aws-for-fluent-bit"
    chart                      = "aws-for-fluent-bit"
    repository                 = "https://aws.github.io/eks-charts"
    version                    = "0.1.11"
    namespace                  = "logging"
    timeout                    = "300"
    create_namespace           = false
    values                     = local.default_helm_values
    set                        = []
    set_sensitive              = null
    lint                       = true
    wait                       = true
    wait_for_jobs              = false
    description                = "aws-for-fluentbit Helm Chart deployment configuration"
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
    aws_region           = var.addon_context.aws_region_name,
    log_group_name       = aws_cloudwatch_log_group.aws_for_fluent_bit.name,
    service_account_name = local.service_account_name
  })]

  argocd_gitops_config = {
    enable             = true
    logGroupName       = aws_cloudwatch_log_group.aws_for_fluent_bit.name
    serviceAccountName = local.service_account_name
  }
}
