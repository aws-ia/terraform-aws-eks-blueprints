locals {
  name = "cluster-proportional-autoscaler"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes-sigs.github.io/cluster-proportional-autoscaler"
    version     = "1.0.0"
    namespace   = "kube-system"
    timeout     = "300"
    values      = local.default_helm_values
    set         = []
    description = "Cluster Proportional Autoscaler Helm Chart"
  }

  set_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    operating_system = "linux"
  })]

  argocd_gitops_config = {
    enable = true
  }
}
