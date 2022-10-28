locals {
  name = "nvidia-device-plugin"

  # https://github.com/NVIDIA/k8s-device-plugin/blob/master/deployments/helm/nvidia-device-plugin/Chart.yaml
  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://nvidia.github.io/k8s-device-plugin"
    version          = "0.12.3"
    namespace        = local.name
    description      = "nvidia-device-plugin Helm Chart deployment configuration"
    create_namespace = true
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
