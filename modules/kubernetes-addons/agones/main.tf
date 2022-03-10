module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  irsa_config       = null
  addon_context     = var.addon_context

  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = local.helm_config["namespace"]

    labels = {
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    }
  }
}

resource "aws_security_group_rule" "agones_sg_ingress_rule" {
  type              = "ingress"
  from_port         = local.helm_config["gameserver_minport"]
  to_port           = local.helm_config["gameserver_maxport"]
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = data.aws_security_group.eks_worker_group.id
}
