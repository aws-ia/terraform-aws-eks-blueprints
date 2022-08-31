locals {
  kyverno_chart_name          = "kyverno"
  kyverno_policies_chart_name = "kyverno-policies"
  kyverno_ui_chart_name       = "policy-reporter"
  namespace                   = "kyverno"
  default_kyverno_values          = [templatefile("${path.module}/kyverno-values.yaml", {})]
  default_kyverno_policies_values = [templatefile("${path.module}/kyverno-policies-values.yaml", {})]
  default_kyverno_ui_values       = [templatefile("${path.module}/kyverno-ui-values.yaml", {})]

  default_kyverno_controller_helm_config = {
    name        = local.kyverno_chart_name
    chart       = local.kyverno_chart_name
    repository  = "https://kyverno.github.io/kyverno/"
    version     = "v2.5.2"
    namespace   = local.namespace
    description = "Kyverno policy engine AddOn Helm Chart"
    values      = local.default_kyverno_values
    timeout     = "1200"
  }

  kyverno_helm_config = merge(
    local.default_kyverno_controller_helm_config,
    var.kyverno_helm_config
  )


  default_kyverno_policies_helm_config = {
    name        = local.kyverno_policies_chart_name
    chart       = local.kyverno_policies_chart_name
    repository  = "https://kyverno.github.io/kyverno/"
    version     = "v2.5.2"
    namespace   = local.namespace
    description = "Kyverno policies AddOn Helm Chart"
    values      = local.default_kyverno_policies_values
    timeout     = "1200"
  }

  kyverno_policies_helm_config = merge(
    local.default_kyverno_policies_helm_config,
    var.kyverno_policies_helm_config
  )


  default_kyverno_ui_helm_config = {
    name        = local.kyverno_ui_chart_name
    chart       = local.kyverno_ui_chart_name
    repository  = "https://kyverno.github.io/policy-reporter"
    version     = "2.11.0"
    namespace   = local.namespace
    description = "Kyverno UI AddOn Helm Chart"
    values      = local.default_kyverno_ui_values
    timeout     = "1200"
  }

  kyverno_ui_helm_config = merge(
    local.default_kyverno_ui_helm_config,
    var.kyverno_ui_helm_config
  )


  argocd_gitops_config = {
    enable = true
  }
}
