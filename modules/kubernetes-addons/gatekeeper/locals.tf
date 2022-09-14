locals {
  name = "gatekeeper"

  default_helm_config = {
    name       = local.name
    chart      = local.name
    repository = "https://open-policy-agent.github.io/gatekeeper/charts"
    version    = "3.9.0"
    namespace  = "gatekeeper-system"
    values = [
      <<-EOT
        clusterName: ${var.addon_context.eks_cluster_id}
      EOT
    ]
    description      = "gatekeeper Helm Chart deployment configuration"
    create_namespace = true
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable      = true
    clusterName = var.addon_context.eks_cluster_id
  }
}
