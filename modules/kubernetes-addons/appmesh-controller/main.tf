module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  set_values        = local.set_values
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "appmesh" {
  name        = "${var.addon_context.eks_cluster_id}-appmesh"
  description = "IAM Policy for App Mesh"
  policy      = data.aws_iam_policy_document.appmesh.json
}
