module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_cloudwatch_log_group" "aws_for_fluent_bit" {
  count             = var.create_cw_log_group ? 1 : 0
  name              = local.log_group_name
  retention_in_days = var.cw_log_group_retention
  kms_key_id        = var.cw_log_group_kms_key_arn == null ? module.kms[0].key_arn : var.cw_log_group_kms_key_arn
  tags              = var.addon_context.tags
}

resource "aws_iam_policy" "aws_for_fluent_bit" {
  name        = "${var.addon_context.eks_cluster_id}-fluentbit"
  description = "IAM Policy for AWS for FluentBit"
  policy      = data.aws_iam_policy_document.irsa.json
  tags        = var.addon_context.tags
}

module "kms" {
  count       = var.cw_log_group_kms_key_arn == null && var.create_cw_log_group ? 1 : 0
  source      = "../../../modules/aws-kms"
  description = "EKS Workers FluentBit CloudWatch Log group KMS Key"
  alias       = "alias/${var.addon_context.eks_cluster_id}-cw-fluent-bit"
  policy      = data.aws_iam_policy_document.kms.json
  tags        = var.addon_context.tags
}
