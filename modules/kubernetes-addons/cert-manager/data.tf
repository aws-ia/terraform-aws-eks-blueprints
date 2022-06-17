data "aws_route53_zone" "selected" {
  for_each = toset(var.domain_names)

  name = each.key
}

data "aws_iam_policy_document" "cert_manager_iam_policy_document" {
  statement {
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:route53:::change/*"]
    actions   = ["route53:GetChange"]
  }

  dynamic "statement" {
    for_each = { for k, v in toset(var.domain_names) : k => data.aws_route53_zone.selected[k].arn }

    content {
      effect    = "Allow"
      resources = [statement.value]
      actions = [
        "route53:ChangeresourceRecordSets",
        "route53:ListresourceRecordSets"
      ]
    }
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["route53:ListHostedZonesByName"]
  }
}
