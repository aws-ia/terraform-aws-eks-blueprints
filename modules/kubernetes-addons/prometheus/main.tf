module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  set_values        = local.amp_config_values
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "ingest" {
  count       = var.enable_amazon_prometheus ? 1 : 0
  name        = format("%s-%s", "amp-ingest", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants ingest (remote write) permissions for AMP workspace"
  policy      = data.aws_iam_policy_document.ingest.json
  tags        = var.addon_context.tags
}
