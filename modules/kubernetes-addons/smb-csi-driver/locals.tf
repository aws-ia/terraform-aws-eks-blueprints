locals {
  name = "csi-driver-smb"
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts"
    version     = "v1.9.0"
    namespace   = "kube-system"
    description = "SMB CSI driver helm Chart deployment configuration"
  }

  default_helm_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    { values = distinct(concat(try(var.helm_config["values"], []), local.default_helm_values)) }
  )

  argocd_gitops_config = {
    enable = true
  }
}
