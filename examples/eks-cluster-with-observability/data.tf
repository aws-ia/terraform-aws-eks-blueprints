data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.aws-eks-accelerator-for-terraform.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.aws-eks-accelerator-for-terraform.eks_cluster_id
}

data "aws_iam_policy_document" "fluentbit-opensearch-access" {
  statement {
    sid       = "OpenSearchAccess"
    effect    = "Allow"
    resources = [aws_elasticsearch_domain.opensearch.arn]
    actions   = ["es:*"]
  }
}
