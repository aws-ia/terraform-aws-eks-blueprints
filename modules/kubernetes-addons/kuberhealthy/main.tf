module "helm_addon" {
  source = "../helm-addon"

  # https://kuberhealthy.github.io/kuberhealthy/helm-repos
  # https://github.com/kuberhealthy/kuberhealthy/tree/master/deploy/helm/kuberhealthy
  helm_config = merge(
    {
      name       = "kuberhealthy"
      chart      = "kuberhealthy"
      repository = "https://kuberhealthy.github.io/kuberhealthy/helm-repos"
      //version          = "v2.7.1"
      namespace        = "kuberhealthy"
      values           = [file("${path.module}/values.yaml")]
      create_namespace = true
      description      = "Kuberhealthy Helm Chart deployment configuration"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
