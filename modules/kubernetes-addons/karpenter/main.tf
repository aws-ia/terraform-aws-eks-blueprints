module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  set_values        = local.set_values
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "karpenter" {
  name        = "${var.addon_context.eks_cluster_id}-karpenter"
  description = "IAM Policy for Karpenter"
  policy      = data.aws_iam_policy_document.karpenter.json
  path        = var.path
}

#tfsec:ignore:aws-sqs-enable-queue-encryption
resource "aws_sqs_queue" "this" {
  count = var.enable_spot_termination ? 1 : 0

  name                              = "karpenter-${var.addon_context.eks_cluster_id}"
  message_retention_seconds         = 300
  sqs_managed_sse_enabled           = var.sqs_queue_managed_sse_enabled
  kms_master_key_id                 = var.sqs_queue_kms_master_key_id
  kms_data_key_reuse_period_seconds = var.sqs_queue_kms_data_key_reuse_period_seconds

  tags = var.addon_context.tags
}

resource "aws_sqs_queue_policy" "this" {
  count = var.enable_spot_termination ? 1 : 0

  queue_url = aws_sqs_queue.this[0].id
  policy    = data.aws_iam_policy_document.sqs_queue[0].json
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for k, v in local.event_rules : k => v if var.enable_spot_termination }

  name_prefix   = "${var.rule_name_prefix}${each.value.name}-"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)
  tags = merge(
    { "ClusterName" : var.addon_context.eks_cluster_id },
    var.addon_context.tags,
  )
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for k, v in local.event_rules : k => v if var.enable_spot_termination }

  rule      = aws_cloudwatch_event_rule.this[each.key].name
  arn       = aws_sqs_queue.this[0].arn
  target_id = "KarpenterInterruptionQueueTarget"
}
