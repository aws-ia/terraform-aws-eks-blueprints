terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.13.3"
    }
  }
}

# Deploys ADOT Operator
module "operator" {
  source            = "../aws-opentelemetry-operator"
  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
}

# Deploys JMX collector CDR
module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.otel_config_values
  helm_config       = local.helm_config
  irsa_config       = null
  addon_context     = var.addon_context

  depends_on = [module.operator]
}

module "irsa_amp_ingest" {
  source                      = "../../../modules/irsa"
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = false
  kubernetes_service_account  = local.amazon_prometheus_ingest_service_account
  irsa_iam_policies           = [aws_iam_policy.ingest.arn]
  addon_context               = var.addon_context

  depends_on = [module.operator]
}

module "irsa_amp_query" {
  source                      = "../../../modules/irsa"
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = false
  kubernetes_service_account  = "amp-query"
  irsa_iam_policies           = [aws_iam_policy.query.arn]
  addon_context               = var.addon_context

  depends_on = [module.operator]
}

resource "aws_iam_policy" "ingest" {
  name        = format("%s-%s", "amp-ingest", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants ingest (remote write) permissions for AMP workspace"
  path        = var.addon_context.irsa_iam_role_path
  policy      = data.aws_iam_policy_document.ingest.json
  tags        = var.addon_context.tags
}

resource "aws_iam_policy" "query" {
  name        = format("%s-%s", "amp-query", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants query permissions for AMP workspace"
  path        = var.addon_context.irsa_iam_role_path
  policy      = data.aws_iam_policy_document.query.json
  tags        = var.addon_context.tags
}


# Configure JMX default Grafana dashboards

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "amp"
  is_default = true
  url        = var.amazon_prometheus_workspace_endpoint
  json_data {
    http_method     = "POST"
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = var.amazon_prometheus_workspace_region
  }
}

resource "grafana_folder" "jmx_dashboards" {
  title = "Observability"

  depends_on = [module.helm_addon]
}

resource "grafana_dashboard" "jmx_dashboards" {
  folder      = grafana_folder.jmx_dashboards.id
  config_json = file("${path.module}/dashboards/default.json")
}


## TODO- AMP alert rules

