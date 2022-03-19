data "aws_iam_policy_document" "ipv6_policy" {
  count = var.enable_ipv6 ? 1 : 0
  statement {
    sid = "IpV6"
    actions = [
      "ec2:AssignIpv6Addresses",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstanceTypes"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "CreateTags"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:${var.addon_context.aws_partition_id}:ec2:*:*:network-interface/*"]
  }
}
