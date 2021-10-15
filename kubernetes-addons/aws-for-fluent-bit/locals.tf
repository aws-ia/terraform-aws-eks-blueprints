
locals {
  default_aws_for_fluent_bit_helm_app = {
    name             = "aws-for-fluent-bit"
    chart            = "aws-for-fluent-bit"
    repository       = "aws/aws-for-fluent-bit"
    version          = "0.1.0"
    namespace        = "logging"
    timeout          = "1200"
    create_namespace = true
    values           = null
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
    set_sensitive              = null
    lint                       = false
    values                     = null
    wait                       = true
    wait_for_jobs              = false
    description                = "aws-for-fluent-bit helm Chart deployment configuration"
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
  aws_for_fluent_bit_helm_app = merge(
    local.default_aws_for_fluent_bit_helm_app,
  var.aws_for_fluent_bit_helm_chart)
}
