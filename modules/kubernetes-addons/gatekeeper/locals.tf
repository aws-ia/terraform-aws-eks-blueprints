locals {
  name                 = "gatekeeper"
  namespace            = "gatekeeper-system"

  default_helm_config = {
    name              = local.name
    chart             = local.name
    repository        = "https://open-policy-agent.github.io/gatekeeper/charts"
    version           = "3.9.0"
    namespace         = local.namespace
    values            = local.default_helm_values
    description       = "gatekeeper Helm Chart deployment configuration"
     create_namespace = true
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    eks_cluster_id = var.addon_context.eks_cluster_id
  })]


  argocd_gitops_config = {
    enable             = true
  }
}
