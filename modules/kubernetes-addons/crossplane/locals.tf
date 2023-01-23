locals {
  namespace = try(var.helm_config.namespace, "crossplane-system")

  # https://github.com/crossplane/crossplane/blob/master/cluster/charts/crossplane/Chart.yaml
  default_helm_config = {
    chart       = "crossplane"
    name        = "crossplane"
    namespace   = local.namespace
    repository  = "https://charts.crossplane.io/stable/"
    version     = "1.10.1"
    description = "Crossplane Helm chart"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  aws_provider = merge({
    provider_aws_version     = "v0.36.0"
    additional_irsa_policies = ["arn:${var.addon_context.aws_partition_id}:iam::aws:policy/AdministratorAccess"]
    name                     = "aws-provider"
    namespace                = local.namespace
    service_account          = "aws-provider"
    provider_config          = "default"
    controller_config        = "aws-controller-config"
    },
    var.aws_provider
  )

  upbound_aws_provider = merge({
    provider_aws_version     = "v0.27.0"
    additional_irsa_policies = ["arn:${var.addon_context.aws_partition_id}:iam::aws:policy/AdministratorAccess"]
    name                     = "upbound-aws-provider"
    namespace                = local.namespace
    service_account          = "upbound-aws-provider"
    provider_config          = "default"
    controller_config        = "upbound-aws-controller-config"
    },
    var.upbound_aws_provider
  )

  kubernetes_provider = merge({
    provider_kubernetes_version = "v0.6.0"
    name                        = "kubernetes-provider"
    service_account             = "kubernetes-provider"
    provider_config             = "default"
    controller_config           = "kubernetes-controller-config"
    cluster_role                = "cluster-admin"
    },
    var.kubernetes_provider
  )

  helm_provider = merge({
    provider_helm_version = "v0.13.0"
    name                  = "provider-helm"
    service_account       = "provider-helm"
    provider_config       = "default"
    controller_config     = "helm-controller-config"
    cluster_role          = "cluster-admin"
    },
    var.helm_provider
  )

  jet_aws_provider_sa = "jet-aws-provider"
}
