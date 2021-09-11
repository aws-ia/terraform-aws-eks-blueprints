resource "aws_security_group" "self_managed_ng" {
  count       = var.custom_security_group_id == "" ? 1 : 0
  name        = "${var.cluster_full_name}-${var.self_managed_ng["self_managed_nodegroup_name"]}"
  description = "Security group for all nodes in the ${var.cluster_full_name} cluster- self managed"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name                                             = "${var.cluster_full_name}-cluster-sg"
      "kubernetes.io/cluster/${var.cluster_full_name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "worker_to_worker_tcp" {
  description              = "Allow workers tcp communication with each other"
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
  source_security_group_id = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_to_worker_udp" {
  count                    = var.custom_security_group_id == "" ? 1 : 0
  description              = "Allow workers udp communication with each other"
  from_port                = 0
  protocol                 = "udp"
  security_group_id        = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
  source_security_group_id = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_masters_ingress" {
  count                    = var.custom_security_group_id == "" ? 1 : 0
  description              = "Allow workes kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
  source_security_group_id = var.cluster_security_group
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_masters_https_ingress" {
  description              = "Allow workers kubelets and pods to receive https from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
  source_security_group_id = var.cluster_security_group
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "masters_api_ingress" {
  description              = "Allow cluster control plane to receive communication from workers kubelets and pods"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "masters_kubelet_egress" {
  description              = "Allow the cluster control plane to reach out workers kubelets and pods"
  from_port                = 10250
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
  to_port                  = 10250
  type                     = "egress"
}

resource "aws_security_group_rule" "masters_kubelet_https_egress" {
  description              = "Allow the cluster control plane to reach out workers kubelets and pods https"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
  to_port                  = 443
  type                     = "egress"
}

resource "aws_security_group_rule" "masters_workers_egress" {
  description              = "Allow the cluster control plane to reach out all worker node security group"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = var.custom_security_group_id == "" ? aws_security_group.self_managed_ng[0].id : var.custom_security_group_id
  type                     = "egress"
}