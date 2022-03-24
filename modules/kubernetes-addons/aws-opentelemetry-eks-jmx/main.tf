resource "helm_release" "prometheus" {
  count = 1

  name      = local.helm_config["name"]
  chart     = "${path.module}/otel-config"
  namespace = local.helm_config["namespace"]
  timeout   = local.helm_config["timeout"]

  values = local.helm_config["values"]

  postrender {
    binary_path = local.helm_config["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = distinct(concat(local.otel_config_values, local.helm_config["set"]))

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  depends_on = [kubernetes_namespace_v1.prometheus]
}

module "irsa_amp_ingest" {
  count = 1

  source                      = "../../../modules/irsa"
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = true
  kubernetes_service_account  = local.amazon_prometheus_ingest_service_account
  irsa_iam_policies           = [aws_iam_policy.ingest[0].arn]
  addon_context               = var.addon_context
}

module "irsa_amp_query" {
  count = 1

  source                      = "../../../modules/irsa"
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = false
  kubernetes_service_account  = "amp-query"
  irsa_iam_policies           = [aws_iam_policy.query[0].arn]
  addon_context               = var.addon_context
}

resource "aws_iam_policy" "ingest" {
  count = 1

  name        = format("%s-%s", "amp-ingest", var.eks_cluster_id)
  description = "Set up the permission policy that grants ingest (remote write) permissions for AMP workspace"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.ingest.json
  tags        = var.addon_context.tags
}

resource "aws_iam_policy" "query" {
  count = 1

  name        = format("%s-%s", "amp-query", var.eks_cluster_id)
  description = "Set up the permission policy that grants query permissions for AMP workspace"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.query.json
  tags        = var.addon_context.tags
}
