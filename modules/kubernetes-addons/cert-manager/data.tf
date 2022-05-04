data "aws_route53_zone" "selected" {
  for_each = contains(var.domain_names, "*") ? {} : { for domain in toset(var.domain_names) : domain => domain }

  name = each.key
}


data "aws_iam_policy_document" "cert_manager_iam_policy_document" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["route53:GetChange"]
  }

  dynamic "statement" {
    for_each = contains(var.domain_names, "*") ? { "*" : "*" } : { for domain in toset(var.domain_names) : domain => data.aws_route53_zone.selected[domain].arn }
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
