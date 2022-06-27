data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = var.private_zone
}

data "aws_iam_policy_document" "external_dns_iam_policy_document" {
  statement {
    effect    = "Allow"
    resources = [data.aws_route53_zone.selected.arn]
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "route53:ListHostedZones",
    ]
  }
}
