
   
data "aws_iam_policy_document" "velero_policy" {
  statement {
    sid = "ec2Actions"
    actions = [
        "ec2:DescribeVolumes",
        "ec2:DescribeSnapshots",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "s3Actions"
    actions   = [
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObject",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts",
        "s3:ListBucket"
  ]
    resources = [
      "arn:aws:s3:::${local.s3bucketname}/*", 
      "arn:aws:s3:::${local.s3bucketname}"
    ]
  }
}