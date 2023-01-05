locals {
  name = "k8ssandra-operator"
  default_helm_config = {
    name             = local.name
    chart            = "k8ssandra-operator"
    repository       = "https://helm.k8ssandra.io/stable"
    version          = "0.39.1"
    namespace        = local.name
    create_namespace = true
    values           = [templatefile("${path.module}/values.yaml", {})]
    description      = "K8ssandra Operator to run Cassandra DB on Kubernetes"
  }
  helm_config = merge(local.default_helm_config, var.helm_config)
}


resource "helm_release" "cert-manager" {
  name  = "cert-manager"
  chart = "cert-manager"
  repository  = "https://charts.jetstack.io"
  version     = "v1.10.0"
  namespace   = "cert-manager"
  create_namespace = true
  description = "Cert Manager Add-on"
  wait        = true
  set {
    name  = "installCRDs"
    value = true
  }

}

#-------------------------------------------------
# K8assandra Operator Helm Add-on
#-------------------------------------------------
module "helm_addon" {
  source            = "../helm-addon"
  helm_config       = local.helm_config
  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
  depends_on = [helm_release.cert-manager]
}
