data "aws_iam_policy_document" "ingest" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "aps:RemoteWrite",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
    ]
  }
}

data "aws_iam_policy_document" "query" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "aps:QueryMetrics",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
    ]
  }
}
