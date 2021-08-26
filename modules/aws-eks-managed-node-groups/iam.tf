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

resource "aws_iam_role" "mg_linux" {
  name_prefix           = "${local.name_prefix_linux}-${local.managed_node_group["node_group_name"]}"
  assume_role_policy    = data.aws_iam_policy_document.mg_linux_assume_role_policy.json
  path                  = var.path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_instance_profile" "mg_linux" {
  name_prefix = "${local.name_prefix_linux}-${local.managed_node_group["node_group_name"]}"
  role        = aws_iam_role.mg_linux.name

  path = var.path
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "mg_linux_AmazonEKSWorkerNodePolicy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.mg_linux.name
}

resource "aws_iam_role_policy_attachment" "mg_linux_AmazonEKS_CNI_Policy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.mg_linux.name
}

resource "aws_iam_role_policy_attachment" "mg_linux_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.mg_linux.name
}

resource "aws_iam_role_policy_attachment" "mg_linux_AmazonSSMManagedInstanceCore" {
  policy_arn = "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.mg_linux.name
}

resource "aws_iam_role_policy_attachment" "mg_linux_CloudWatchFullAccess" {
  policy_arn = "${local.policy_arn_prefix}/CloudWatchFullAccess"
  role       = aws_iam_role.mg_linux.name
}

resource "aws_iam_role_policy_attachment" "mg_linux_ElasticLoadBalancingFullAccess" {
  policy_arn = "${local.policy_arn_prefix}/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.mg_linux.name
}

resource "aws_iam_role_policy_attachment" "mg_linux_AmazonPrometheusRemoteWriteAccess" {
  count      = var.aws_managed_prometheus_enable ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonPrometheusRemoteWriteAccess"
  role       = aws_iam_role.mg_linux.name
}

resource "aws_iam_role_policy_attachment" "mg_linux_cluster_autoscaler" {
  count      = var.cluster_autoscaler_enable ? 1 : 0
  policy_arn = aws_iam_policy.eks_autoscaler_policy[0].arn
  role       = aws_iam_role.mg_linux.name
}

resource "aws_iam_policy" "eks_autoscaler_policy" {
  count = var.cluster_autoscaler_enable ? 1 : 0

  name        = "${local.name_prefix_linux}-${local.managed_node_group["node_group_name"]}"
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
