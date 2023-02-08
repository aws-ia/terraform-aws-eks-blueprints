locals {
  name             = try(var.helm_config.name, "appmesh-prometheus")
  namespace_name   = try(var.helm_config.namespace, "appmesh-system")
  create_namespace = try(var.helm_config.create_namespace, false) && local.namespace_name != "kube-system"

  argocd_gitops_config = {
    enable               = true
    serviceAccountName   = local.name
    serviceAccountCreate = true
  }

  default_helm_config = {
    name        = local.name
    chart       = "appmesh-prometheus"
    repository  = "https://aws.github.io/eks-charts"
    namespace   = local.namespace_name
    description = "App Mesh Prometheus helm Chart deployment configuration"
    values = [templatefile("${path.module}/values.yaml", {
      operating_system = try(var.helm_config.operating_system, "linux")
    })]
    version = "1.0.1"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.name
    },
    {
      name  = "serviceAccount.create"
      value = true
    }
  ]

}

module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  addon_context     = var.addon_context
}

resource "kubernetes_namespace_v1" "prometheus" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name = local.namespace_name
  }
}
