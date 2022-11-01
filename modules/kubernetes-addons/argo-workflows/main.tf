locals {
  name = "argo-workflows"

  # https://github.com/argoproj/argo-helm/tree/main/charts/argo-workflows
  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://argoproj.github.io/argo-helm"
    version          = "v0.20.1"
    namespace        = local.name
    create_namespace = true
    description      = "Argo events Helm chart deployment configuration"
  }

  helm_config = merge(local.default_helm_config, var.helm_config)

  argocd_gitops_config = {
    enable = true
  }
}

module "helm_addon" {
  source = "../helm-addon"

  helm_config   = local.helm_config
  addon_context = var.addon_context
}

resource "kubernetes_namespace_v1" "this" {
  count = try(local.helm_config["create_namespace"], true) && local.helm_config["namespace"] != "kube-system" ? 1 : 0
  metadata {
    name = local.helm_config["namespace"]
  }
}
