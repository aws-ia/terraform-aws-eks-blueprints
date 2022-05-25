resource "aws_iam_role" "fargate" {
  count = local.fargate_profiles["create_iam_role"] ? 1 : 0

  name                  = "${var.context.eks_cluster_id}-${local.fargate_profiles["fargate_profile_name"]}"
  description           = "EKS Fargate IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.fargate_assume_role_policy.json
  path                  = var.context.iam_role_path
  permissions_boundary  = var.context.iam_role_permissions_boundary
  force_detach_policies = true
  tags                  = var.context.tags
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_role_policy" {
  for_each   = local.fargate_policies
  policy_arn = each.key
  role       = aws_iam_role.fargate[0].name
}

resource "aws_iam_policy" "cwlogs" {
  count = local.fargate_profiles["create_iam_role"] ? 1 : 0

  name        = "${var.context.eks_cluster_id}-${local.fargate_profiles["fargate_profile_name"]}-cwlogs"
  description = "Allow fargate profiles to write logs to CloudWatch"
  path        = var.context.iam_role_path
  policy      = data.aws_iam_policy_document.cwlogs.json
  tags        = var.context.tags
}

resource "aws_iam_role_policy_attachment" "cwlogs" {
  count = local.fargate_profiles["create_iam_role"] ? 1 : 0

  policy_arn = aws_iam_policy.cwlogs[0].arn
  role       = aws_iam_role.fargate[0].name
}
