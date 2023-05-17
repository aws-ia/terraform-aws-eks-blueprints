module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/Chart.yaml
  helm_config = merge(
    {
      name             = "kubecost"
      chart            = "cost-analyzer"
      repository       = "oci://public.ecr.aws/kubecost"
      version          = "1.103.3"
      namespace        = "kubecost"
      values           = [file("${path.module}/values.yaml")]
      create_namespace = true
      description      = "Kubecost Helm Chart deployment configuration"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
