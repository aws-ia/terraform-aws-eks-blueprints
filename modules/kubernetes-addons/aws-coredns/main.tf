locals {
  name = "coredns"
}

data "aws_eks_addon_version" "this" {
  addon_name = local.name
  # Need to allow both config routes - for managed and self-managed configs
  kubernetes_version = try(var.addon_config.kubernetes_version, var.helm_config.kubernetes_version)
  most_recent        = try(var.addon_config.most_recent, var.helm_config.most_recent, false)
}

resource "aws_eks_addon" "coredns" {
  count = var.enable_amazon_eks_coredns ? 1 : 0

  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = local.name
  addon_version            = try(var.addon_config.addon_version, data.aws_eks_addon_version.this.version)
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
  count  = var.enable_self_managed_coredns ? 1 : 0

  helm_config = merge({
    name        = local.name
    description = "CoreDNS is a DNS server that chains plugins and provides Kubernetes DNS Services"
    chart       = local.name
    repository  = "https://coredns.github.io/helm"
    namespace   = "kube-system"
    values = [
      <<-EOT
      image:
        repository: ${var.helm_config.image_registry}/eks/coredns
        tag: ${data.aws_eks_addon_version.this.version}
      deployment:
        name: coredns
        annotations:
          eks.amazonaws.com/compute-type: ${try(var.helm_config.compute_type, "ec2")}
      service:
        name: kube-dns
        annotations:
          eks.amazonaws.com/compute-type: ${try(var.helm_config.compute_type, "ec2")}
      podAnnotations:
        eks.amazonaws.com/compute-type: ${try(var.helm_config.compute_type, "ec2")}
      EOT
    ]
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
