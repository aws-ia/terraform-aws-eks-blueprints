resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      istio-injection = "enabled"
    }
  }
}

module "istio_base" {
  source = "../helm-addon"
  count  = var.install_istio_base ? 1 : 0

  helm_config = merge(
    {
      name            = "istio-base"
      chart           = "base"
      repository      = "https://istio-release.storage.googleapis.com/charts"
      version         = var.istio_version
      namespace       = kubernetes_namespace.istio_system.metadata.0.name
      timeout         = 120
      cleanup_on_fail = var.cleanup_on_fail
      force_update    = var.force_update
      values = [
        yamlencode(var.istio_base_settings)
      ]
      description = "Helm chart for deploying Istio cluster resources and CRDs"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context

  depends_on = [kubernetes_namespace.istio_system]
}

module "istio_cni" {
  source = "../helm-addon"
  count  = var.install_istio_cni ? 1 : 0

  helm_config = merge(
    {
      name            = "istio-cni"
      chart           = "cni"
      repository      = "https://istio-release.storage.googleapis.com/charts"
      version         = var.istio_version
      namespace       = kubernetes_namespace.istio_system.metadata.0.name
      timeout         = 120
      cleanup_on_fail = var.cleanup_on_fail
      force_update    = var.force_update
      values = [
        yamlencode(
          {
            istio_cni = {
              enabled = var.install_istio_cni
            }
          }
        )
      ]
      description = "Helm chart for istio-cni components"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context

  depends_on = [module.istio_base]
}

module "istiod" {
  source = "../helm-addon"
  count  = var.install_istiod ? 1 : 0

  helm_config = merge(
    {
      name            = "istiod"
      chart           = "istiod"
      repository      = "https://istio-release.storage.googleapis.com/charts"
      version         = var.istio_version
      namespace       = kubernetes_namespace.istio_system.metadata.0.name
      timeout         = 120
      cleanup_on_fail = var.cleanup_on_fail
      force_update    = var.force_update
      values = [
        yamlencode(
          {
            global = {
              network = var.istiod_global_network
              meshID  = var.istiod_global_meshID
              multiCluster = {
                clusterName = var.addon_context.eks_cluster_id
              }
            }
            meshConfig = {
              rootNamespaces = var.istiod_meshConfig_rootNamespace
              trustDomain    = var.istiod_meshConfig_trustDomain
              accessLogFile  = var.istiod_meshConfig_accessLogFile
              enableAutoMtls = var.istiod_meshConfig_enableAutoMtls
            }
          }
        )
      ]
      description = "Helm chart for istio control plane"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context

  depends_on = [module.istio_cni]
}

module "istio_ingressgateway" {
  source = "../helm-addon"
  count  = var.install_istio_ingressgateway ? 1 : 0

  helm_config = merge(
    {
      name            = "istio-ingressgateway"
      chart           = "gateway"
      repository      = "https://istio-release.storage.googleapis.com/charts"
      version         = var.istio_version
      namespace       = kubernetes_namespace.istio_system.metadata.0.name
      timeout         = 120
      cleanup_on_fail = var.cleanup_on_fail
      force_update    = var.force_update
      values = [
        yamlencode(var.istio_gateway_settings)
      ]
      description = "Helm chart for deploying Istio gateways"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context

  depends_on = [module.istiod]
}
