locals {
  name      = "kuberay-operator"
  namespace = try(var.helm_config.namespace, "ray-system")
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = local.namespace
  }
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/ray-project/kuberay/blob/master/helm-chart/kuberay-operator/Chart.yaml
  helm_config = merge(
    {
      name        = "kuberay/${local.name}"
      chart       = "https://ray-project.github.io/kuberay-helm/"
      version     = "0.4.0"
      namespace   = kubernetes_namespace_v1.this.metadata[0].name
      description = "KubeRay Operator Helm Chart deployment configuration"
    },
    var.helm_config
  )

  addon_context = var.addon_context
}
