module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "cluster_autoscaler" {
  description = "Cluster Autoscaler IAM policy"
  name        = "${var.addon_context.eks_cluster_id}-${local.helm_config["name"]}-irsa"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
  tags        = var.addon_context.tags
}
