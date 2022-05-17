locals {
  name = "coredns"
}

resource "aws_eks_addon" "coredns" {
  count = var.use_managed_addon ? 1 : 0

  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = local.name
  addon_version            = try(var.addon_config.addon_version, null)
  resolve_conflicts        = try(var.addon_config.resolve_conflicts, "OVERWRITE")
  service_account_role_arn = try(var.addon_config.service_account_role_arn, null)
  preserve                 = try(var.addon_config.preserve, true)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}

module "helm_addon" {
  source = "../helm-addon"
  count  = var.use_managed_addon ? 0 : 1

  helm_config = merge({
    name        = try(var.helm_config.name, local.name)
    description = try(var.helm_config.description, "CoreDNS is a DNS server that chains plugins and provides Kubernetes DNS Services")
    chart       = try(var.helm_config.chart, local.name)
    repository  = try(var.helm_config.repository, "https://coredns.github.io/helm")
    namespace   = try(var.helm_config.namespace, "kube-system")
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.create"
      value = true
    }
  ]

  # Blueprints
  addon_context = var.addon_context
}
