module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/kubernetes-sigs/cluster-proportional-autoscaler/blob/master/charts/cluster-proportional-autoscaler/Chart.yaml
  helm_config = merge(
    {
      name       = "cluster-proportional-autoscaler"
      chart      = "cluster-proportional-autoscaler"
      repository = "https://kubernetes-sigs.github.io/cluster-proportional-autoscaler"
      version    = "1.0.1"
      namespace  = "kube-system"
      values = [templatefile("${path.module}/values.yaml", {
        operating_system = "linux"
      })]
      description = "Cluster Proportional Autoscaler Helm Chart"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
