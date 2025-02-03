################################################################################
# Device Plugin(s)
################################################################################

resource "helm_release" "nvidia_device_plugin" {
  name             = "nvidia-device-plugin"
  repository       = "https://nvidia.github.io/k8s-device-plugin"
  chart            = "nvidia-device-plugin"
  version          = "0.17.0"
  namespace        = "nvidia-device-plugin"
  create_namespace = true
  wait             = false
}

resource "helm_release" "aws_efa_device_plugin" {
  name       = "aws-efa-k8s-device-plugin"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-efa-k8s-device-plugin"
  version    = "v0.5.7"
  namespace  = "kube-system"
  wait       = false

  values = [
    <<-EOT
      nodeSelector:
        vpc.amazonaws.com/efa.present: 'true'
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
    EOT
  ]
}

################################################################################
# LWS (LeaderWorkerSet)
################################################################################

locals {
  lws_version = "v0.5.0"
}

data "http" "lws" {
  url = "https://github.com/kubernetes-sigs/lws/releases/download/${local.lws_version}/manifests.yaml"
}

data "kubectl_file_documents" "lws" {
  content = data.http.lws.response_body
}

resource "kubectl_manifest" "lws" {
  for_each = data.kubectl_file_documents.lws.manifests

  yaml_body         = each.value
  server_side_apply = true
}
