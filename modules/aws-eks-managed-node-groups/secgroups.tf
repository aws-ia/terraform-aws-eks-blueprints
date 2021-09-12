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

resource "aws_security_group" "managed_ng" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  name        = "${var.eks_cluster_name}-${local.managed_node_group["node_group_name"]}"
  description = "Security group for all nodes in the ${var.eks_cluster_name} cluster - Fully managed node groups"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group_rule" "worker_to_worker_tcp" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow workers tcp communication with each other"
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = aws_security_group.managed_ng[0].id
  source_security_group_id = aws_security_group.managed_ng[0].id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_to_worker_udp" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow workers udp communication with each other"
  from_port                = 0
  protocol                 = "udp"
  security_group_id        = aws_security_group.managed_ng[0].id
  source_security_group_id = aws_security_group.managed_ng[0].id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_masters_ingress" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow workes kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.managed_ng[0].id
  source_security_group_id = var.cluster_primary_security_group_id
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_masters_https_ingress" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow workers kubelets and pods to receive https from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.managed_ng[0].id
  source_security_group_id = var.cluster_primary_security_group_id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "masters_api_ingress" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow cluster control plane to receive communication from workers kubelets and pods"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_primary_security_group_id
  source_security_group_id = aws_security_group.managed_ng[0].id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "masters_kubelet_egress" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow the cluster control plane to reach out workers kubelets and pods"
  from_port                = 10250
  protocol                 = "tcp"
  security_group_id        = var.cluster_primary_security_group_id
  source_security_group_id = aws_security_group.managed_ng[0].id
  to_port                  = 10250
  type                     = "egress"
}

resource "aws_security_group_rule" "masters_kubelet_https_egress" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow the cluster control plane to reach out workers kubelets and pods https"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_primary_security_group_id
  source_security_group_id = aws_security_group.managed_ng[0].id
  to_port                  = 443
  type                     = "egress"
}

resource "aws_security_group_rule" "masters_workers_egress" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow the cluster control plane to reach out all worker node security group"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = var.cluster_primary_security_group_id
  source_security_group_id = aws_security_group.managed_ng[0].id
  type                     = "egress"
}