locals {
  argocd_gitops_config = {
    enable      = true
    clusterName = var.addon_context.eks_cluster_id
  }
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/open-policy-agent/gatekeeper/blob/master/charts/gatekeeper/Chart.yaml
  helm_config = merge(
    {
      name             = "gatekeeper"
      chart            = "gatekeeper"
      description      = "gatekeeper Helm Chart deployment configuration"
      repository       = "https://open-policy-agent.github.io/gatekeeper/charts"
      version          = "3.10.0"
      namespace        = "gatekeeper-system"
      create_namespace = true
      values = [
        <<-EOT
          clusterName: ${var.addon_context.eks_cluster_id}
        EOT
      ]
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
