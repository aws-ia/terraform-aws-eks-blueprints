locals {
  name = "datadog-operator"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://helm.datadoghq.com"
    version          = "0.8.6"
    namespace        = local.name
    create_namespace = true
    description      = "The Datadog Operator Helm chart default configuration"
    values           = null
    timeout          = "1200"
    datadog_agent    = {}
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }

  datadog_agent = merge(yamldecode(templatefile("${path.module}/datadog_agent.yaml", {
    cluster_name        = var.addon_context.eks_cluster_id
    namespace           = local.helm_config["namespace"]
    api_secret_name     = "datadog-secret"
    api_secret_key_name = "api-key"
    })),
    try(var.helm_config.datadog_agent, {})
  )

}
