module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  set_values        = local.amp_config_values
  irsa_config       = null
  addon_context     = var.addon_context

  depends_on = [module.irsa_amp_ingest, module.irsa_amp_query]
}

module "irsa_amp_ingest" {
  count                         = var.enable_amazon_prometheus ? 1 : 0
  source                        = "../../../modules/irsa"
  kubernetes_namespace          = local.helm_config["namespace"]
  create_kubernetes_namespace   = true
  kubernetes_service_account    = local.amazon_prometheus_ingest_service_account
  iam_role_path                 = var.irsa_role_path
  irsa_iam_policies             = [aws_iam_policy.ingest[0].arn]
  irsa_iam_permissions_boundary = var.irsa_permissions_boundary
  addon_context                 = var.addon_context
}

module "irsa_amp_query" {
  count                         = var.enable_amazon_prometheus ? 1 : 0
  source                        = "../../../modules/irsa"
  kubernetes_namespace          = local.helm_config["namespace"]
  create_kubernetes_namespace   = false
  kubernetes_service_account    = "amp-query"
  iam_role_path                 = var.irsa_role_path
  irsa_iam_policies             = [aws_iam_policy.query[0].arn]
  irsa_iam_permissions_boundary = var.irsa_permissions_boundary
  addon_context                 = var.addon_context
}

resource "aws_iam_policy" "ingest" {
  count       = var.enable_amazon_prometheus ? 1 : 0
  name        = format("%s-%s", "amp-ingest", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants ingest (remote write) permissions for AMP workspace"
  policy      = data.aws_iam_policy_document.ingest.json
  tags        = var.addon_context.tags
}

resource "aws_iam_policy" "query" {
  count       = var.enable_amazon_prometheus ? 1 : 0
  name        = format("%s-%s", "amp-query", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants query permissions for AMP workspace"
  policy      = data.aws_iam_policy_document.query.json
  tags        = var.addon_context.tags
}
