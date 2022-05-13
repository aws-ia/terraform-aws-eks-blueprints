locals {
  namespace            = "kube-system"
  name                 = "aws-node-termination-handler"
  service_account_name = "${local.name}-sa"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://aws.github.io/eks-charts"
    version          = "0.16.0"
    namespace        = local.namespace
    timeout          = "1200"
    create_namespace = false
    description      = "AWS Node Termination Handler Helm Chart"
    values           = local.default_helm_values
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]
}