locals {
  namespace = try(var.helm_config.namespace, "crossplane-system")

  # https://github.com/crossplane/crossplane/blob/master/cluster/charts/crossplane/Chart.yaml
  default_helm_config = {
    name        = "crossplane"
    chart       = "crossplane"
    repository  = "https://charts.crossplane.io/stable/"
    version     = "1.10.1"
    namespace   = local.namespace
    description = "Crossplane Helm chart"
    values      = local.default_helm_values
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    operating-system = "linux"
  })]

  aws_provider = merge({
    provider_aws_version     = "v0.34.0"
    additional_irsa_policies = ["arn:${var.addon_context.aws_partition_id}:iam::aws:policy/AdministratorAccess"]
    name                     = "aws-provider"
    service_account          = "aws-provider"
    provider_config          = "default"
    controller_config        = "aws-controller-config"
    },
    var.aws_provider
  )
  kubernetes_provider = merge({
    provider_kubernetes_version = "v0.5.0"
    name                        = "kubernetes-provider"
    service_account             = "kubernetes-provider"
    provider_config             = "default"
    controller_config           = "kubernetes-controller-config"
    cluster_role                = "cluster-admin"
    },
    var.kubernetes_provider
  )
  jet_aws_provider_sa = "jet-aws-provider"
}
