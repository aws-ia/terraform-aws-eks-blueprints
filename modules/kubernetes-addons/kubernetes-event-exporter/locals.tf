locals {
  name = "kubernetes-event-exporter"

  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://charts.bitnami.com/bitnami"
      version          = "v2.2.4"
      namespace        = local.name
      create_namespace = true
      values           = [templatefile("${path.module}/values.yaml", {})]
      description      = "kube-event-exporter"
    },
    var.helm_config
  )

}
