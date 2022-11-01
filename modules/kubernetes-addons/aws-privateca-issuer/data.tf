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
