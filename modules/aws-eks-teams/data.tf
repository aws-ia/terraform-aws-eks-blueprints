data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_id
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "platform_team_eks_access" {
  count = length(var.platform_teams) > 0 ? 1 : 0
  statement {
    sid = "AllowPlatformTeamEKSAccess"
    actions = [
      "eks:AccessKubernetesApi",
      "eks:DescribeCluster",
      "eks:DescribeNodegroup",
      "eks:ListClusters",
      "eks:ListFargateProfiles",
      "eks:ListNodegroups",
      "eks:ListUpdates",
      "ssm:GetParameter",
    ]
    resources = [
      data.aws_eks_cluster.eks_cluster.arn
    ]
  }

  statement {
    sid       = "AllowListClusters"
    actions   = ["eks:ListClusters"]
    resources = ["*"]
  }
}
