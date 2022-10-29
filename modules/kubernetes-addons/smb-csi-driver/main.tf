module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/kubernetes-csi/csi-driver-smb/blob/master/charts/latest/csi-driver-smb/Chart.yaml
  helm_config = merge(
    {
      name        = "csi-driver-smb"
      chart       = "csi-driver-smb"
      repository  = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts"
      version     = "v1.9.0"
      namespace   = "kube-system"
      description = "SMB CSI driver helm Chart deployment configuration"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
