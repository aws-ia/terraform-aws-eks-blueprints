module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  set_values        = var.enable_amazon_prometheus
  irsa_config       = null
  addon_context     = var.addon_context

  depends_on = [irsa_amp_ingest, irsa_amp_query]
}

module "irsa_amp_ingest" {
  count                       = var.enable_amazon_prometheus ? 1 : 0
  source                      = "../../../modules/irsa"
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = true
  kubernetes_service_account  = local.amazon_prometheus_ingest_service_account
  irsa_iam_policies           = [aws_iam_policy.ingest[0].arn]
  addon_context               = var.addon_context
}

module "irsa_amp_query" {
  count                       = var.enable_amazon_prometheus ? 1 : 0
  source                      = "../../../modules/irsa"
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = false
  kubernetes_service_account  = "amp-query"
  irsa_iam_policies           = [aws_iam_policy.query[0].arn]
  addon_context               = var.addon_context
}

resource "aws_iam_policy" "ingest" {
  count       = var.enable_amazon_prometheus ? 1 : 0
  name        = format("%s-%s", "amp-ingest", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants ingest (remote write) permissions for AMP workspace"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.ingest.json
  tags        = var.addon_context.tags
}

resource "aws_iam_policy" "query" {
  count       = var.enable_amazon_prometheus ? 1 : 0
  name        = format("%s-%s", "amp-query", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants query permissions for AMP workspace"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.query.json
  tags        = var.addon_context.tags
}
