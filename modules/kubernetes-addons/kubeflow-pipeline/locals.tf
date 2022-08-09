locals {
  name = "kubeflow-pipelines"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://getindata.github.io/helm-charts"
    version     = "1.6.2"
    namespace   = local.name
    description = "The kubeflow pipeline HelmChart deployment configuration"
    values      = local.default_helm_values
    timeout     = "300"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
  })]

  argocd_gitops_config = {
    enable = true
  }
}
