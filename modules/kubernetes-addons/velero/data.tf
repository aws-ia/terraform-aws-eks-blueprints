# https://github.com/vmware-tanzu/velero-plugin-for-aws#option-1-set-permissions-with-an-iam-user
data "aws_iam_policy_document" "velero" {
  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot"
    ]
    resources = [
      "arn:${var.addon_context.aws_partition_id}:ec2:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:instance/*",
      "arn:${var.addon_context.aws_partition_id}:ec2:${var.addon_context.aws_region_name}::snapshot/*",
      "arn:${var.addon_context.aws_partition_id}:ec2:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:volume/*"
    ]
  }

  statement {
    actions = [
      "ec2:DescribeSnapshots",
      "ec2:DescribeVolumes"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["arn:${var.addon_context.aws_partition_id}:s3:::${var.backup_s3_bucket}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:${var.addon_context.aws_partition_id}:s3:::${var.backup_s3_bucket}"]
  }
}
