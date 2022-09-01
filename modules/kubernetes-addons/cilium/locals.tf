locals {
  name = "cilium"
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://helm.cilium.io/"
    version     = "1.12.1"
    namespace   = "kube-system"
    description = "cilium helm Chart deployment configuration"
  }

  set_values_vpc_cni = [
    {
      name  = "cni.chainingMode"
      value = "aws-cni"
    },
    {
      name  = "enableIPv4Masquerade"
      value = false
    },
    {
      name  = "tunnel"
      value = "disabled"
    }
  ]

  set_values_default_cni = [
    {
      name  = "eni.enabled"
      value = true
    },
    {
      name  = "ipam.mode"
      value = "eni"
    },
    {
      name  = "egressMasqueradeInterfaces"
      value = "eth0"
    },
    {
      name  = "tunnel"
      value = "disabled"
    },
    {
      name  = "nodeinit.enabled"
      value = true
    },
    {
      name  = "hubble.relay.enabled"
      value = true
    },
    {
      name  = "hubble.ui.enabled"
      value = true
    }
  ]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = concat(try(local.helm_config["default_cni"], false) ? local.set_values_default_cni : local.set_values_vpc_cni, try(var.helm_config.set_values, []))

  argocd_gitops_config = {
    enable = true
  }
}
