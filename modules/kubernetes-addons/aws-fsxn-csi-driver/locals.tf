locals {
  name = "trident-operator"
  namespace = "trident"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://netapp.github.io/trident-helm-chart"
    version          = "23.01.0"
    namespace        = local.namespace
    create_namespace = true
    values           = local.default_helm_values
    set              = []
    description      = "Amazon FSx for NetApp ONTAP CSI storage provisioner using the Trident Operator."
    wait             = false
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  helm_config = merge(local.default_helm_config,var.helm_config)
  irsa_config = {}
}