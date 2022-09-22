locals {
  name                 = "datadog"
  namespace            = try(var.helm_config.namespace, local.name)

  default_helm_config = {
    name              = local.name
    chart             = local.name
    create_namespace  = true
    repository        = "https://helm.datadoghq.com"
    version           = "3.1.1"
    namespace         = local.namespace
    description       = "Datadog Agent Helm Chart"
    values            = []
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable  = true
  }
}
