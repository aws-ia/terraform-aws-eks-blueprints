resource "aws_iam_role" "fargate" {
  name                  = "${var.eks_cluster_name}-${local.fargate_profiles["fargate_profile_name"]}"
  assume_role_policy    = data.aws_iam_policy_document.fargate_assume_role_policy.json
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

resource "aws_iam_policy" "cwlogs" {
  name        = "${var.eks_cluster_name}-${local.fargate_profiles["fargate_profile_name"]}-cwlogs"
  description = "Allow fargate profiles to write logs to CloudWatch"
  path        = var.path
  policy      = data.aws_iam_policy_document.cwlogs.json
}

resource "aws_iam_role_policy_attachment" "cwlogs" {
  policy_arn = aws_iam_policy.cwlogs.arn
  role       = aws_iam_role.fargate.name
}
