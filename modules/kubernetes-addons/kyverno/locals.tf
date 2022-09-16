locals {
  kyverno_chart_name                 = "kyverno"
  kyverno_policies_chart_name        = "kyverno-policies"
  kyverno_policy_reporter_chart_name = "policy-reporter"
  namespace                          = "kyverno"
  default_kyverno_values             = [templatefile("${path.module}/kyverno-values.yaml", {})]
  default_kyverno_policies_values    = [templatefile("${path.module}/kyverno-policies-values.yaml", {})]


  kyverno_helm_config = merge(
    {
      name        = local.kyverno_chart_name
      chart       = local.kyverno_chart_name
      repository  = "https://kyverno.github.io/kyverno/"
      version     = "v2.5.3"
      namespace   = local.namespace
      description = "Kyverno policy engine AddOn Helm Chart"
      values      = local.default_kyverno_values
    },
    var.kyverno_helm_config
  )

  kyverno_policies_helm_config = merge(
    {
      name        = local.kyverno_policies_chart_name
      chart       = local.kyverno_policies_chart_name
      repository  = "https://kyverno.github.io/kyverno/"
      version     = "v2.5.5"
      namespace   = local.namespace
      description = "Kyverno policies AddOn Helm Chart"
      values      = local.default_kyverno_policies_values
    },
    var.kyverno_policies_helm_config
  )

  kyverno_policy_reporter_helm_config = merge(
    {
      name        = local.kyverno_policy_reporter_chart_name
      chart       = local.kyverno_policy_reporter_chart_name
      repository  = "https://kyverno.github.io/policy-reporter"
      version     = "2.12.1"
      namespace   = local.namespace
      description = "Kyverno UI AddOn Helm Chart"
    },
    var.kyverno_policy_reporter_helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
