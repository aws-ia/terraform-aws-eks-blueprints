module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

data "aws_iam_policy_document" "aws_privateca_issuer" {
  statement {
    effect    = "Allow"
    resources = [var.aws_privateca_acmca_arn]
    actions = [
      "acm-pca:DescribeCertificateAuthority",
      "acm-pca:GetCertificate",
      "acm-pca:IssueCertificate",
    ]
  }
}

resource "aws_iam_policy" "aws_privateca_issuer" {
  description = "AWS PCA issuer IAM policy"
  name        = "${var.addon_context.eks_cluster_id}-${local.helm_config["name"]}-irsa"
  policy      = data.aws_iam_policy_document.aws_privateca_issuer.json
  tags        = var.addon_context.tags
}
