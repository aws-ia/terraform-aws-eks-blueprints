data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid       = "VisualEditor0"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:s3:::*"]

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:Get*",
      "s3:ListBucket",
      "s3:Put*",
    ]
  }

  statement {
    sid       = "VisualEditor1"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["s3:ListAllMyBuckets"]
  }
}
