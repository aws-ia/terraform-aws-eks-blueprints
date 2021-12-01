resource "aws_iam_role" "self_managed_ng" {
  name                  = "${var.eks_cluster_name}-${local.self_managed_node_group["node_group_name"]}"
  assume_role_policy    = data.aws_iam_policy_document.self_managed_ng_assume_role_policy.json
  path                  = var.path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_instance_profile" "self_managed_ng" {
  name = "${var.eks_cluster_name}-${local.self_managed_node_group["node_group_name"]}"
  role = aws_iam_role.self_managed_ng.name

  path = var.path
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "self_managed_AmazonEKSWorkerNodePolicy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.self_managed_ng.name
}

resource "aws_iam_role_policy_attachment" "self_managed_AmazonEKS_CNI_Policy" {
  count      = local.enable_windows_support ? 0 : 1
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.self_managed_ng.name
}

resource "aws_iam_role_policy_attachment" "self_managed_windows_nodes_cni" {
  count      = local.enable_windows_support ? 1 : 0
  policy_arn = aws_iam_policy.eks_windows_cni.0.arn
  role       = aws_iam_role.self_managed_ng.name
}

resource "aws_iam_role_policy_attachment" "self_managed_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.self_managed_ng.name
}

# Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${var.eks_cluster_name}-${local.self_managed_node_group["node_group_name"]}-ca"
  description = "IAM policy for Cluster Autoscaler"
  path        = var.path
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.self_managed_ng.name
}

# CloudWatch Log access
resource "aws_iam_policy" "cwlogs" {
  name        = "${var.eks_cluster_name}-${local.self_managed_node_group["node_group_name"]}-cwlogs"
  description = "IAM policy for CloudWatch Logs access"
  path        = var.path
  policy      = data.aws_iam_policy_document.cwlogs.json
}

resource "aws_iam_role_policy_attachment" "cwlogs" {
  policy_arn = aws_iam_policy.cwlogs.arn
  role       = aws_iam_role.self_managed_ng.name
}
# Windows nodes only need read-only access to EC2
resource "aws_iam_policy" "eks_windows_cni" {
  count       = local.enable_windows_support ? 1 : 0
  name        = "${var.eks_cluster_name}-${local.self_managed_node_group["node_group_name"]}-cni-policy"
  description = "EKS Windows CNI policy"
  path        = var.path
  policy      = data.aws_iam_policy_document.eks_windows_cni.json
}

resource "aws_iam_role_policy_attachment" "eks_windows_cni" {
  count      = local.enable_windows_support ? 1 : 0
  policy_arn = aws_iam_policy.eks_windows_cni[0].arn
  role       = aws_iam_role.self_managed_ng.name
}
