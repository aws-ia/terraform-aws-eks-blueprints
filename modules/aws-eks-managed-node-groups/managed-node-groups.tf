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

resource "aws_eks_node_group" "managed_ng" {

  cluster_name           = var.eks_cluster_name
  node_group_name_prefix = local.managed_node_group["node_group_name"]
  //   node_group_name = ""     # Optional when node_group_name_prefix is defined
  node_role_arn = aws_iam_role.mg_linux.arn
  subnet_ids    = local.managed_node_group["subnet_ids"]

  scaling_config {
    desired_size = local.managed_node_group["desired_size"]
    max_size     = local.managed_node_group["max_size"]
    min_size     = local.managed_node_group["min_size"]
  }

  ami_type       = local.managed_node_group["ami_type"] != "" ? local.managed_node_group["ami_type"] : null
  capacity_type  = local.managed_node_group["capacity_type"]
  disk_size      = local.managed_node_group["create_launch_template"] == true ? null : local.managed_node_group["disk_size"]
  instance_types = local.managed_node_group["instance_types"]
  //  force_update_version = lookup(each.value, "force_update_version", null)

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  dynamic "launch_template" {
    for_each = local.managed_node_group["create_launch_template"] == true ? [{
      id      = aws_launch_template.managed_node_groups.id
      version = aws_launch_template.managed_node_groups.default_version
    }] : []
    content {
      id      = launch_template.value["id"]
      version = launch_template.value["version"]
    }
  }

  dynamic "remote_access" {
    for_each = local.managed_node_group["remote_access"] == true ? [1] : []
    content {
      ec2_ssh_key               = local.managed_node_group["ec2_ssh_key"]
      source_security_group_ids = local.managed_node_group["source_security_group_ids"]
    }
  }

  dynamic "taint" {
    for_each = local.managed_node_group["k8s_taints"]
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  labels = local.managed_node_group["k8s_labels"]

  tags = merge(var.tags, local.managed_node_group["additional_tags"])

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }

  depends_on = [
    aws_iam_role_policy_attachment.mg_linux_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.mg_linux_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.mg_linux_AmazonEC2ContainerRegistryReadOnly,
  ]

}