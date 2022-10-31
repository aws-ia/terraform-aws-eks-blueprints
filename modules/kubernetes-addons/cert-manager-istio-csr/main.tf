module "helm_addon" {
  source = "../helm-addon"
  helm_config = merge(
    {
      name             = "cert-manager-istio-csr"
      chart            = "cert-manager-istio-csr"
      repository       = "https://charts.jetstack.io"
      version          = "v0.5.0"
      namespace        = "cert-manager"
      create_namespace = false
      description      = "Cert-manager-istio-csr Helm Chart deployment configuration"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
