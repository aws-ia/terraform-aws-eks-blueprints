data "aws_iam_policy_document" "this" {
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    resources = ["arn:aws:s3:::example-log-bucket-name"]

    actions = [
      "s3:ListBucket"
    ]
  }

  statement {
    sid       = "WriteToLogs"
    effect    = "Allow"
    resources = ["arn:aws:s3:::example-log-bucket-name/*"]

    actions = [
      "s3:PutObject"
    ]
  }
}
