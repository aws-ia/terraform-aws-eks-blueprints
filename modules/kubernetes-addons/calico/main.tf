module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/projectcalico/calico/blob/master/charts/tigera-operator/Chart.yaml
  helm_config = merge(
    {
      name       = "calico"
      chart      = "tigera-operator"
      repository = "https://docs.projectcalico.org/charts"
      version    = "v3.24.3"
      namespace  = "tigera-operator"
      values = [
        <<-EOT
          installation:
            kubernetesProvider: "EKS"
        EOT
      ]
      create_namespace = true
      description      = "calico helm Chart deployment configuration"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
