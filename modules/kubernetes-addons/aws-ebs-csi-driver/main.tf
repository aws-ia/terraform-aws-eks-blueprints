locals {
  create_irsa = try(var.addon_config.service_account_role_arn == "", true)
  name        = try(var.helm_config.name, "aws-ebs-csi-driver")
  namespace   = try(var.helm_config.namespace, "kube-system")
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  count                    = var.enable_amazon_eks_aws_ebs_csi_driver && !var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0
  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = try(var.addon_config.addon_version, null)
  resolve_conflicts        = try(var.addon_config.resolve_conflicts, null)
  service_account_role_arn = local.create_irsa ? module.irsa_addon[0].irsa_iam_role_arn : try(var.addon_config.service_account_role_arn, null)
  preserve                 = try(var.addon_config.preserve, true)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}

module "irsa_addon" {
  source = "../../../modules/irsa"

  count = local.create_irsa && !var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0

  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = "ebs-csi-controller-sa"
  irsa_iam_policies                 = concat([aws_iam_policy.aws_ebs_csi_driver[0].arn], try(var.addon_config.additional_iam_policies, []))
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

module "helm_addon" {
  source = "../helm-addon"
  count  = var.enable_self_managed_aws_ebs_csi_driver && !var.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0

  helm_config = merge({
    name        = local.name
    description = "The Amazon Elastic Block Store Container Storage Interface (CSI) Driver provides a CSI interface used by Container Orchestrators to manage the lifecycle of Amazon EBS volumes."
    chart       = "aws-ebs-csi-driver"
    version     = "2.10.1"
    repository  = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
    namespace   = local.namespace
    values = [
      <<-EOT
      image:
        repository: public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver
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
    create_kubernetes_namespace       = try(var.helm_config.create_namespace, false)
    kubernetes_namespace              = local.namespace
    create_kubernetes_service_account = true
    kubernetes_service_account        = "ebs-csi-controller-sa"
    irsa_iam_policies                 = concat([aws_iam_policy.aws_ebs_csi_driver[0].arn], try(var.helm_config.additional_iam_policies, []))
  }

  # Blueprints
  addon_context = var.addon_context
}
