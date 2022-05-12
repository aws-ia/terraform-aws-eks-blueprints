data "aws_iam_policy_document" "fluentbit_opensearch_access" {
  statement {
    sid       = "OpenSearchAccess"
    effect    = "Allow"
    resources = ["${aws_elasticsearch_domain.opensearch.arn}/*"]
    actions   = ["es:ESHttp*"]
  }
}

data "aws_iam_policy_document" "opensearch_access_policy" {
  statement {
    effect    = "Allow"
    resources = ["${aws_elasticsearch_domain.opensearch.arn}/*"]
    actions   = ["es:ESHttp*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
