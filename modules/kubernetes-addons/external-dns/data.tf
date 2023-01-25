data "aws_iam_policy_document" "external_dns_iam_policy_document" {
  statement {
    effect = "Allow"
    resources = distinct(concat(
      [data.aws_route53_zone.selected.arn],
      var.route53_zone_arns
    ))
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["route53:ListHostedZones"]
  }
}
