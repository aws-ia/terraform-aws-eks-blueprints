module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/cilium/cilium/blob/f5c39586866486ab3532f2a3947e50cf7350763d/install/kubernetes/cilium/Chart.yaml
  helm_config = merge(
    {
      name       = "cilium"
      chart      = "cilium"
      repository = "https://helm.cilium.io/"
      version    = "1.12.3"
      namespace  = "kube-system"
      values = [
        <<-EOT
          cni:
            chainingMode: aws-cni
          enableIPv4Masquerade: false
          tunnel: disabled
          endpointRoutes:
            enabled: true
          %{if var.enable_wireguard}
          l7Proxy: false
          encryption:
            enabled: true
            type: wireguard
          %{endif}
        EOT
      ]
      description = "eBPF-based Networking, Security, and Observability"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
