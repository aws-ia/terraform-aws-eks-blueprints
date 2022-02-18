locals {
  namespace = "crossplane-system"

  default_helm_config = {
    name        = "crossplane"
    chart       = "crossplane"
    repository  = "https://charts.crossplane.io/stable/"
    version     = "1.6.2"
    namespace   = local.namespace
    description = "Crossplane Helm chart"
    values      = local.default_helm_values
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    operating-system = "linux"
  })]

  default_provider_aws = {
    enable = true
    version = "v0.23.0"
    additional_irsa_policies = []
  }

  provider_aws = merge(
    local.default_provider_aws,
    var.provider_aws
  )

  default_provider_jet_aws = {
    enable = true
    version = "v0.4.1"
    additional_irsa_policies = []
  }

  provider_jet_aws = merge(
    local.default_provider_jet_aws,
    var.provider_jet_aws
  )

  argocd_gitops_config = {
    enable = true
  }
}
