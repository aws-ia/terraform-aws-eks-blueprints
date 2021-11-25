locals {
  log_group_name      = "/${var.eks_cluster_id}/worker-fluentbit-logs"
  log_group_retention = 90

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region     = data.aws_region.current.name,
    log_group_name = local.log_group_name
  })]

  default_aws_for_fluentbit_helm_app = {
    name                       = "aws-for-fluent-bit"
    chart                      = "aws-for-fluent-bit"
    repository                 = "https://aws.github.io/eks-charts"
    version                    = "0.1.11"
    namespace                  = "kube-system"
    timeout                    = "1200"
    create_namespace           = true
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

  aws_for_fluentbit_helm_app = merge(
    local.default_aws_for_fluentbit_helm_app,
    var.aws_for_fluentbit_helm_chart
  )

  argocd_gitops_config = {
    enable       = true
    logGroupName = aws_cloudwatch_log_group.eks_worker_logs.name
  }
}
