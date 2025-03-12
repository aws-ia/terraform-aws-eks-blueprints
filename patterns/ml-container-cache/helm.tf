################################################################################
# Helm charts
################################################################################

resource "helm_release" "nvidia_device_plugin" {
  name             = "nvidia-device-plugin"
  repository       = "https://nvidia.github.io/k8s-device-plugin"
  chart            = "nvidia-device-plugin"
  version          = "0.17.1" # Matches image that is cached
  namespace        = "nvidia-device-plugin"
  create_namespace = true
  wait             = false
}
