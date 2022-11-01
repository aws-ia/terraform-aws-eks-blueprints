module "kyverno_helm_addon" {
  source = "../helm-addon"

  manage_via_gitops = var.manage_via_gitops
  # https://github.com/kyverno/kyverno/blob/main/charts/kyverno/Chart.yaml
  helm_config = merge(
    {
      name             = "kyverno"
      chart            = "kyverno"
      repository       = "https://kyverno.github.io/kyverno/"
      version          = "v2.5.3"
      namespace        = "kyverno"
      create_namespace = true
      description      = "Kubernetes Native Policy Management"
      values = [
        <<-EOT
          replicaCount: 3
        EOT
      ]
    },
    var.kyverno_helm_config
  )

  addon_context = var.addon_context
}

module "kyverno_policies_helm_addon" {
  source = "../helm-addon"

  count = var.enable_kyverno_policies ? 1 : 0

  manage_via_gitops = var.manage_via_gitops
  # https://github.com/kyverno/kyverno/blob/main/charts/kyverno-policies/Chart.yaml
  helm_config = merge(
    {
      name        = "kyverno-policies"
      chart       = "kyverno-policies"
      repository  = "https://kyverno.github.io/kyverno/"
      version     = "v2.5.5"
      namespace   = module.kyverno_helm_addon.helm_release[0].namespace
      description = "Kubernetes Pod Security Standards implemented as Kyverno policies"
      values = [
        <<-EOT
          podSecurityStandard: restricted
        EOT

      ]
    },
    var.kyverno_policies_helm_config
  )

  addon_context = var.addon_context
}

module "kyverno_policy_reporter_helm_addon" {
  source = "../helm-addon"

  count = var.enable_kyverno_policy_reporter ? 1 : 0

  manage_via_gitops = var.manage_via_gitops
  # https://github.com/kyverno/policy-reporter/blob/main/charts/policy-reporter/Chart.yaml
  helm_config = merge(
    {
      name        = "policy-reporter"
      chart       = "policy-reporter"
      repository  = "https://kyverno.github.io/policy-reporter"
      version     = "2.13.4"
      namespace   = module.kyverno_helm_addon.helm_release[0].namespace
      description = "Policy Reporter watches for PolicyReport Resources"
    },
    var.kyverno_policy_reporter_helm_config
  )

  addon_context = var.addon_context
}
