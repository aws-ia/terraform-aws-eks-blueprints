data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_eks_cluster" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = module.aws_eks.cluster_id
}

data "http" "eks_cluster_readiness" {
  count = var.create_eks ? 1 : 0

  url            = join("/", [data.aws_eks_cluster.cluster[0].endpoint, "healthz"])
  ca_certificate = base64decode(data.aws_eks_cluster.cluster[0].certificate_authority[0].data)
  timeout        = var.eks_readiness_timeout
}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_iam_policy_document" "eks_key" {
  statement {
    sid    = "Allow access for all principals in the account that are authorized"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:root"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.context.aws_caller_identity_account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["eks.${local.context.aws_region_name}.amazonaws.com"]
    }
  }

  statement {
    sid    = "Allow direct access to key metadata to the account"
    effect = "Allow"
    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*",
      "kms:RevokeGrant",
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:root"
      ]
    }
  }

  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = concat(
        var.cluster_kms_key_additional_admin_arns,
        [data.aws_iam_session_context.current.issuer_arn]
      )
    }
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        local.cluster_iam_role_pathed_arn
      ]
    }
  }

  # Permission to allow AWS services that are integrated with AWS KMS to use the CMK,
  # particularly services that use grants.
  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        local.cluster_iam_role_pathed_arn
      ]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
