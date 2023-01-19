data "aws_iam_policy_document" "aws_vpc_cni_metrics" {
  statement {
    sid = "CNIMetrics"
    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}
