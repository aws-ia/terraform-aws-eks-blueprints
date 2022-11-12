module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/cert-manager/csi-driver/blob/main/deploy/charts/csi-driver/Chart.yaml
  helm_config = merge(
    {
      name        = "cert-manager-csi-driver"
      chart       = "cert-manager-csi-driver"
      repository  = "https://charts.jetstack.io"
      version     = "v0.4.2"
      namespace   = "cert-manager"
      description = "Cert Manager CSI Driver Add-on"
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
