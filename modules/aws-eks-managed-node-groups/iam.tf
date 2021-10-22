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

#TODO Allow IAM policies can be passed from tfvars file
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

resource "aws_iam_role_policy_attachment" "managed_ng_AmazonSSMManagedInstanceCore" {
  policy_arn = "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.managed_ng.name
}

resource "aws_iam_role_policy_attachment" "managed_ng_CloudWatchFullAccess" {
  policy_arn = "${local.policy_arn_prefix}/CloudWatchFullAccess"
  role       = aws_iam_role.managed_ng.name
}

resource "aws_iam_role_policy_attachment" "managed_ng_ElasticLoadBalancingFullAccess" {
  policy_arn = "${local.policy_arn_prefix}/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.managed_ng.name
}

resource "aws_iam_role_policy_attachment" "managed_ng_AmazonPrometheusRemoteWriteAccess" {
  policy_arn = "${local.policy_arn_prefix}/AmazonPrometheusRemoteWriteAccess"
  role       = aws_iam_role.managed_ng.name
}

resource "aws_iam_role_policy_attachment" "managed_ng_cluster_autoscaler" {
  policy_arn = aws_iam_policy.eks_autoscaler_policy.arn
  role       = aws_iam_role.managed_ng.name
}

resource "aws_iam_policy" "eks_autoscaler_policy" {
  name        = "${var.eks_cluster_name}-${local.managed_node_group["node_group_name"]}"
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
