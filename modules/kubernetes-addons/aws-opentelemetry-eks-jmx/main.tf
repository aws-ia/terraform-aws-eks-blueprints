module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.otel_config_values
  helm_config       = local.helm_config
  irsa_config       = null
  addon_context     = var.addon_context

  depends_on = [kubernetes_namespace_v1.prometheus]
}


resource "kubernetes_namespace_v1" "prometheus" {
  metadata {
    name = local.helm_config["namespace"]
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    }
  }
}




module "irsa_amp_ingest" {
  count = 1

  source                      = "../../../modules/irsa"
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = false
  kubernetes_service_account  = local.amazon_prometheus_ingest_service_account
  irsa_iam_policies           = [aws_iam_policy.ingest[0].arn]
  addon_context               = var.addon_context

  depends_on = [kubernetes_namespace_v1.prometheus]
}

module "irsa_amp_query" {
  count = 1

  source                      = "../../../modules/irsa"
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = false
  kubernetes_service_account  = "amp-query"
  irsa_iam_policies           = [aws_iam_policy.query[0].arn]
  addon_context               = var.addon_context

  depends_on = [kubernetes_namespace_v1.prometheus]
}

resource "aws_iam_policy" "ingest" {
  count = 1

  name        = format("%s-%s", "amp-ingest", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants ingest (remote write) permissions for AMP workspace"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.ingest.json
  tags        = var.addon_context.tags
}

resource "aws_iam_policy" "query" {
  count = 1

  name        = format("%s-%s", "amp-query", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants query permissions for AMP workspace"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.query.json
  tags        = var.addon_context.tags
}
