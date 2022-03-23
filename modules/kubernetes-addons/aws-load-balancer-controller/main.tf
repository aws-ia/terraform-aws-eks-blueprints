module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.addon_context.eks_cluster_id}-lb-irsa"
  description = "Allows lb controller to manage ALB and NLB"
  policy      = data.aws_iam_policy_document.aws_lb.json
  tags        = var.addon_context.tags
}
