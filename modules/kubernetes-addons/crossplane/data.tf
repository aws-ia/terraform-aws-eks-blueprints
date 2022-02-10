data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "kubectl_path_documents" "aws_provider" {
  pattern = "${path.module}/aws-provider/provider-aws.yaml"
  vars = {
    provider-aws-version  = var.crossplane_provider_aws.provider_aws_version
    iam-role-arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_id}-provider-aws--irsa"
  }
}

data "kubectl_path_documents" "aws_provider_config" {
  pattern = "${path.module}/aws-provider/aws-provider-config.yaml"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid       = "VisualEditor0"
    effect    = "Allow"
    resources = ["arn:aws:s3:::*"]

    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:CreateBucket",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:DeleteBucket",
      "s3:DeleteObjectVersion"
    ]
  }

  statement {
    sid       = "VisualEditor1"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["s3:ListAllMyBuckets"]
  }
}