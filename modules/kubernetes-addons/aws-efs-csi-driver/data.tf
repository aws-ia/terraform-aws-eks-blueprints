#-------------------------------------------------
# IRSA IAM policy for EFS CSI Driver
#-------------------------------------------------
resource "aws_iam_policy" "aws_efs_csi_driver" {
  name        = "${var.addon_context.eks_cluster_id}-efs-csi-policy"
  description = "IAM Policy for AWS EFS CSI Driver"
  policy      = data.aws_iam_policy_document.aws_efs_csi_driver.json
  tags        = var.addon_context.tags
}

data "aws_iam_policy_document" "aws_efs_csi_driver" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["elasticfilesystem:CreateAccessPoint"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["elasticfilesystem:DeleteAccessPoint"]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}