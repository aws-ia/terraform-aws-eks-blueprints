/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.self_managed_ng.name
}

resource "aws_iam_role_policy_attachment" "self_managed_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.self_managed_ng.name
}

resource "aws_iam_role_policy_attachment" "self_managed_AmazonSSMManagedInstanceCore" {
  policy_arn = "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"
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

