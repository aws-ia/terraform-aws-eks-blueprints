locals {
  name                 = "vpa"
  service_account_name = "vpa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://charts.fairwinds.com/stable"
    version     = "1.0.0"
    namespace   = local.name
    description = "Kubernetes Vertical Pod Autoscaler"
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    sa-name = local.service_account_name
  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account_name
    }
  ]

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
