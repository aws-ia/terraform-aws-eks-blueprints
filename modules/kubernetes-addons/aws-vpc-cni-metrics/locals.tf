locals {
  name            = "cni-metrics-helper"
  service_account = try(var.helm_config.service_account, local.name)
  version         = var.addon_version

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://aws.github.io/eks-charts"
    version          = "0.1.15"
    namespace        = "kube-system"
    create_namespace = false
    values           = null
    description      = "aws-load-balancer-controller Helm Chart for ingress resources"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = concat(
    [
      {
        name  = "serviceAccount.name"
        value = local.service_account
      },
      {
        name  = "serviceAccount.create"
        value = true
      },
      {
        name  = "env.AWS_VPC_K8S_CNI_LOGLEVEL"
        value = "INFO"
      },
      {
        name  = "image.override"
        value = "${var.addon_context.default_repository}/cni-metrics-helper:${local.version}"
      }
    ],
    try(var.helm_config.set_values, [])
  )


}
