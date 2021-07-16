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

resource "aws_iam_role" "windows" {
  name_prefix           = local.name_prefix_windows
  assume_role_policy    = data.aws_iam_policy_document.windows_assume_role_policy.json
  path                  = var.path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_instance_profile" "windows" {
  name_prefix = local.name_prefix_windows
  role        = aws_iam_role.windows.name

  path = var.path
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "windows_AmazonEKSWorkerNodePolicy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.windows.name
}

resource "aws_iam_role_policy_attachment" "windows_AmazonEKS_CNI_Policy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.windows.name
}

resource "aws_iam_role_policy_attachment" "windows_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.windows.name
}

resource "aws_iam_role_policy_attachment" "windows_AmazonSSMManagedInstanceCore" {
  policy_arn = "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.windows.name
}

resource "aws_iam_role_policy_attachment" "windows_CloudWatchFullAccess" {
  policy_arn = "${local.policy_arn_prefix}/CloudWatchFullAccess"
  role       = aws_iam_role.windows.name
}

resource "aws_iam_role_policy_attachment" "windows_AmazonPrometheusRemoteWriteAccess" {
  count      = var.aws_managed_prometheus_enable ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonPrometheusRemoteWriteAccess"
  role       = aws_iam_role.windows.name
}

resource "aws_iam_role" "linux" {
  name_prefix           = local.name_prefix_linux
  assume_role_policy    = data.aws_iam_policy_document.linux_assume_role_policy.json
  path                  = var.path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_instance_profile" "linux" {
  name_prefix = local.name_prefix_linux
  role        = aws_iam_role.linux.name

  path = var.path
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "linux_AmazonEKSWorkerNodePolicy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.linux.name
}

resource "aws_iam_role_policy_attachment" "linux_AmazonEKS_CNI_Policy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.linux.name
}

resource "aws_iam_role_policy_attachment" "linux_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.linux.name
}

resource "aws_iam_role_policy_attachment" "linux_AmazonSSMManagedInstanceCore" {
  policy_arn = "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.linux.name
}

resource "aws_iam_role_policy_attachment" "linux_CloudWatchFullAccess" {
  policy_arn = "${local.policy_arn_prefix}/CloudWatchFullAccess"
  role       = aws_iam_role.linux.name
}

resource "aws_iam_role_policy_attachment" "linux_AmazonPrometheusRemoteWriteAccess" {
  count      = var.aws_managed_prometheus_enable ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonPrometheusRemoteWriteAccess"
  role       = aws_iam_role.linux.name
}

resource "aws_iam_role_policy_attachment" "linux_cluster_autoscaler" {
  count      = var.cluster_autoscaler_enable ? 1 : 0
  policy_arn = var.autoscaler_policy_arn
  role       = aws_iam_role.linux.name
}
