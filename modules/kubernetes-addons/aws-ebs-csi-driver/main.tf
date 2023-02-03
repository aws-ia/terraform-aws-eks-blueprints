locals {
  name = "aws-ebs-csi-driver"

  create_irsa     = try(var.addon_config.service_account_role_arn == "", true)
  namespace       = try(var.helm_config.namespace, "kube-system")
  service_account = try(var.helm_config.service_account, "ebs-csi-controller-sa")
}

data "aws_eks_addon_version" "this" {
  addon_name = local.name
  # Need to allow both config routes - for managed and self-managed configs
  kubernetes_version = try(var.addon_config.kubernetes_version, var.helm_config.kubernetes_version)
  most_recent        = try(var.addon_config.most_recent, var.helm_config.most_recent, false)
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  count                    = var.enable_amazon_eks_aws_ebs_csi_driver && !var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0
  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = local.name
  addon_version            = try(var.addon_config.addon_version, data.aws_eks_addon_version.this.version)
  resolve_conflicts        = try(var.addon_config.resolve_conflicts, "OVERWRITE")
  service_account_role_arn = local.create_irsa ? module.irsa_addon[0].irsa_iam_role_arn : try(var.addon_config.service_account_role_arn, null)
  preserve                 = try(var.addon_config.preserve, true)
  configuration_values     = try(var.addon_config.configuration_values, null)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}

module "helm_addon" {
  source = "../helm-addon"
  count  = var.enable_self_managed_aws_ebs_csi_driver && !var.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0

  # https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/charts/aws-ebs-csi-driver/Chart.yaml
  helm_config = merge({
    name        = local.name
    description = "The Amazon Elastic Block Store Container Storage Interface (CSI) Driver provides a CSI interface used by Container Orchestrators to manage the lifecycle of Amazon EBS volumes."
    chart       = local.name
    version     = "2.12.1"
    repository  = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
    namespace   = local.namespace
    values = [
      <<-EOT
      image:
        repository: public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver
        tag: ${try(var.helm_config.addon_version, replace(data.aws_eks_addon_version.this.version, "/-eksbuild.*/", ""))}
      controller:
        k8sTagClusterId: ${var.addon_context.eks_cluster_id}
      EOT
    ]
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "controller.serviceAccount.create"
      value = "false"
    }
  ]

  irsa_config = {
    create_kubernetes_namespace         = try(var.helm_config.create_namespace, false)
    kubernetes_namespace                = local.namespace
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(var.helm_config["create_service_account_secret_token"], false)
    kubernetes_service_account          = local.service_account
    irsa_iam_policies                   = concat([aws_iam_policy.aws_ebs_csi_driver[0].arn], lookup(var.helm_config, "additional_iam_policies", []))
  }

  # Blueprints
  addon_context = var.addon_context
}

module "irsa_addon" {
  source = "../../../modules/irsa"

  count = local.create_irsa && !var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0

  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = local.service_account
  irsa_iam_policies                 = concat([aws_iam_policy.aws_ebs_csi_driver[0].arn], lookup(var.addon_config, "additional_iam_policies", []))
  irsa_iam_role_path                = var.addon_context.irsa_iam_role_path
  irsa_iam_permissions_boundary     = var.addon_context.irsa_iam_permissions_boundary
  eks_cluster_id                    = var.addon_context.eks_cluster_id
  eks_oidc_provider_arn             = var.addon_context.eks_oidc_provider_arn
}

resource "aws_iam_policy" "aws_ebs_csi_driver" {
  count = local.create_irsa || var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0

  name        = "${var.addon_context.eks_cluster_id}-aws-ebs-csi-driver-irsa"
  description = "IAM Policy for AWS EBS CSI Driver"
  path        = try(var.addon_context.irsa_iam_role_path, null)
  policy      = data.aws_iam_policy_document.aws_ebs_csi_driver[0].json

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}
