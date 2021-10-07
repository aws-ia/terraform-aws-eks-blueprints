
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

  depends_on = [aws_iam_role.managed_ng]
}

resource "aws_security_group_rule" "worker_to_worker_sgr" {
  count                    = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0
  description              = "Allow workers to communication with each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.managed_ng[0].id
  source_security_group_id = aws_security_group.managed_ng[0].id
}

//----------------------------------------------------------------------------------------------------------------------
//  Adding Control Plane Security group id(Additional Security Group ID) to Worker Security group
//----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group_rule" "worker_ingress_from_control_plane_https" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow workers kubelets and pods to receive https from the control plane sec group"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.managed_ng[0].id
  source_security_group_id = var.cluster_security_group_id
}

resource "aws_security_group_rule" "workers_ingress_control_plane_sgr" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow pods running on workers to receive communication from control plane sec group"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.managed_ng[0].id
  source_security_group_id = var.cluster_security_group_id

}

resource "aws_security_group_rule" "control_plane_ingress_from_worker_https" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow workers kubelets and pods to send https to cluster control plane sec group"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group_id
  source_security_group_id = aws_security_group.managed_ng[0].id
}

resource "aws_security_group_rule" "control_plane_egress_to_worker_sgr" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow cluster security group to send communication to worker security groups"
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group_id
  source_security_group_id = aws_security_group.managed_ng[0].id

}

resource "aws_security_group_rule" "control_plane_egress_to_worker_https" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow cluster security group to send communication to worker security groups"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group_id
  source_security_group_id = aws_security_group.managed_ng[0].id

}
//----------------------------------------------------------------------------------------------------------------------
//  Adding Cluster Security group id to Worker Security group
//----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group_rule" "workers_ingress_cluster_primary_sgr" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow pods running on workers to receive communication from cluster primary security group"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  security_group_id        = aws_security_group.managed_ng[0].id
  source_security_group_id = var.cluster_primary_security_group_id
}

resource "aws_security_group_rule" "cluster_primary_sg_ingress_worker_sgr" {
  count = local.managed_node_group["create_worker_security_group"] == true ? 1 : 0

  description              = "Allow pods running on workers to send communication to cluster primary security group"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  security_group_id        = var.cluster_primary_security_group_id
  source_security_group_id = aws_security_group.managed_ng[0].id
}
