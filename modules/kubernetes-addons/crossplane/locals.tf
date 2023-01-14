locals {
  validate_only_one_enabled = var.upbound_aws_provider.enable && var.aws_provider.enable ? tobool("The upbound crossplane provider and crossplane upstream aws provider cannot be enabled at the same time.") : true

  #  namespace = !local.aws_provider.enable && local.upbound_aws_provider.enable ? try(var.helm_config.namespace, "upbound-system") : try(var.helm_config.namespace, "crossplane-system")

  # https://github.com/crossplane/crossplane/blob/master/cluster/charts/crossplane/Chart.yaml
  default_helm_config = {
    name        = "crossplane"
    chart       = "crossplane"
    repository  = "https://charts.crossplane.io/stable/"
    version     = "1.10.1"
    namespace   = try(var.helm_config.namespace, "crossplane-system")
    description = "Crossplane Helm chart"
    values = [(file("${path.module}/default-values.yaml"))]
  }

  # https://github.com/upbound/universal-crossplane/tree/main/cluster/charts/universal-crossplane
  upbound_helm_config = {
    name        = "crossplane"
    chart       = "universal-crossplane"
    repository  = "https://charts.upbound.io/stable/"
    version     = "1.10.1"
    namespace   = try(var.helm_config.namespace, "upbound-system")
    description = "Upbound Universal Crossplane (UXP)"
    values = [(file("${path.module}/upbound-values.yaml"))]
  }

  config = var.upbound_aws_provider.enable ? local.upbound_helm_config : local.default_helm_config
  namespace = var.upbound_aws_provider.enable ? local.upbound_aws_provider.namespace : local.aws_provider.namespace

  helm_config = merge(
    local.config,
    var.helm_config
  )

  aws_provider = merge({
    provider_aws_version     = "v0.34.0"
    additional_irsa_policies = ["arn:${var.addon_context.aws_partition_id}:iam::aws:policy/AdministratorAccess"]
    name                     = "aws-provider"
    namespace                = try(var.helm_config.namespace, "crossplane-system")
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

  upbound_aws_provider = merge({
    provider_aws_version     = "v0.27.0"
    additional_irsa_policies = ["arn:${var.addon_context.aws_partition_id}:iam::aws:policy/AdministratorAccess"]
    name                     = "upbound-aws-provider"
    namespace                = try(var.helm_config.namespace, "upbound-system")
    service_account          = "upbound-aws-provider"
    provider_config          = "default"
    controller_config        = "upbound-aws-controller-config"
    },
    var.upbound_aws_provider
  )
}
