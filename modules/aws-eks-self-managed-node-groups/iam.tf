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

resource "aws_iam_role_policy_attachment" "self_managed_AmazonSSMManagedInstanceCore" {
  policy_arn = "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.self_managed_ng.name
}

resource "aws_iam_role_policy_attachment" "self_managed_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.self_managed_ng.name
}


resource "aws_iam_role_policy_attachment" "self_managed_cloudWatchFullAccess" {
  policy_arn = "${local.policy_arn_prefix}/CloudWatchFullAccess"
  role       = aws_iam_role.self_managed_ng.name
}

resource "aws_iam_role_policy_attachment" "self_managed_ElasticLoadBalancingFullAccess" {
  policy_arn = "${local.policy_arn_prefix}/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.self_managed_ng.name
}

resource "aws_iam_role_policy_attachment" "self_managed_AmazonPrometheusRemoteWriteAccess" {
  policy_arn = "${local.policy_arn_prefix}/AmazonPrometheusRemoteWriteAccess"
  role       = aws_iam_role.self_managed_ng.name
}

resource "aws_iam_role_policy_attachment" "self_managed_cluster_autoscaler" {
  policy_arn = aws_iam_policy.eks_autoscaler_policy.arn
  role       = aws_iam_role.self_managed_ng.name
}

resource "aws_iam_policy" "eks_autoscaler_policy" {

  name        = "${var.eks_cluster_name}-${local.self_managed_node_group["node_group_name"]}-policy"
  path        = "/"
  description = "eks autoscaler policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "arn:aws:autoscaling:*:${data.aws_caller_identity.current.account_id}:autoScalingGroup:*:autoScalingGroupName/*"
    }
  ]
}
EOF
}

# Windows nodes only need read-only access to EC2
resource "aws_iam_policy" "eks_windows_cni" {
  count       = local.enable_windows_support ? 1 : 0
  name        = "${var.eks_cluster_name}-${local.self_managed_node_group["node_group_name"]}-cni-policy"
  path        = "/"
  description = "EKS Windows CNI policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeInstanceTypes"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}