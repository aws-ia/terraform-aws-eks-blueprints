module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/chaos-mesh/chaos-mesh/blob/master/helm/chaos-mesh/Chart.yaml
  helm_config = merge(
    {
      name             = "chaos-mesh"
      chart            = "chaos-mesh"
      repository       = "https://charts.chaos-mesh.org"
      version          = "2.4.1"
      namespace        = "chaos-testing"
      create_namespace = true
      description      = "chaos mesh helm Chart deployment configuration"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
