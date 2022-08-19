data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "http" "eks_cluster_readiness" {
  count = var.create_eks ? 1 : 0

  url            = "${module.aws_eks.cluster_endpoint}/healthz"
  ca_certificate = base64decode(module.aws_eks.cluster_certificate_authority_data)
  timeout        = var.eks_readiness_timeout
}
