# ------------------------------------------
# AMP Ingest Permissions
# ------------------------------------------
data "aws_iam_policy_document" "ingest" {
  statement {
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:aps:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:workspace/*",
      "arn:${var.addon_context.aws_partition_id}:aps:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:workspace/*/*",
    ]

    actions = [
      "aps:ListWorkspaces",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
      "aps:GetSeries",
      "aps:RemoteWrite",
    ]
  }
}

# ------------------------------------------
# AMP Query Permissions
# ------------------------------------------
data "aws_iam_policy_document" "query" {
  statement {
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:aps:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:workspace/*",
      "arn:${var.addon_context.aws_partition_id}:aps:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:workspace/*/*",
    ]

    actions = [
      "aps:ListWorkspaces",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
      "aps:GetSeries",
      "aps:QueryMetrics",
    ]
  }
}
