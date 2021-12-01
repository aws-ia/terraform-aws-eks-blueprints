resource "aws_iam_role" "managed_ng" {
  name                  = "${var.eks_cluster_name}-${local.managed_node_group["node_group_name"]}"
  assume_role_policy    = data.aws_iam_policy_document.managed_ng_assume_role_policy.json
  path                  = var.path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_instance_profile" "managed_ng" {
  name = "${var.eks_cluster_name}-${local.managed_node_group["node_group_name"]}"
  role = aws_iam_role.managed_ng.name

  path = var.path
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "managed_ng_AmazonEKSWorkerNodePolicy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.managed_ng.name
}

resource "aws_iam_role_policy_attachment" "managed_ng_AmazonEKS_CNI_Policy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.managed_ng.name
}

resource "aws_iam_role_policy_attachment" "managed_ng_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.managed_ng.name
}

# Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${var.eks_cluster_name}-${local.managed_node_group["node_group_name"]}-ca"
  description = "IAM policy for Cluster Autoscaler"
  path        = var.path
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.managed_ng.name
}

# CloudWatch Log access
resource "aws_iam_policy" "cwlogs" {
  name        = "${var.eks_cluster_name}-${local.managed_node_group["node_group_name"]}-cwlogs"
  description = "IAM policy for CloudWatch Logs access"
  path        = var.path
  policy      = data.aws_iam_policy_document.cwlogs.json
}

resource "aws_iam_role_policy_attachment" "cwlogs" {
  policy_arn = aws_iam_policy.cwlogs.arn
  role       = aws_iam_role.managed_ng.name
}
