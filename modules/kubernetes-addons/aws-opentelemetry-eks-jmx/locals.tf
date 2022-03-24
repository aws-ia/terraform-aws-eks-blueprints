locals {
  default_helm_config = {
    name             = "opentelemetry"
    repository       = null
    chart            = "${path.module}/otel-config"
    version          = "0.1.0"
    namespace        = "opentelemetry-operator-system"
    timeout          = "1200"
    create_namespace = true
    description      = "ADOT helm Chart deployment configuration"
    lint             = false
    values           = []
    set              = []
    set_sensitive    = null
    postrender       = ""
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )


  amazon_prometheus_ingest_service_account = "amp-ingest"
  amazon_prometheus_ingest_iam_role_arn    = (var.amazon_prometheus_workspace_endpoint != null) ? module.irsa_amp_ingest[0].irsa_iam_role_arn : ""

  otel_config_values = [
    {
      name  = "ampurl"
      value = "${var.amazon_prometheus_workspace_endpoint}api/v1/remote_write"
    },
    {
      name  = "region"
      value = var.amazon_prometheus_workspace_region
    },
    {
      name  = "prometheusMetricsEndpoint"
      value = "metrics"
    },
    {
      name  = "prometheusMetricsPort"
      value = 8888
    },
    {
      name  = "scrapeInterval"
      value = "15s"
    },
    {
      name  = "scrapeTimeout"
      value = "10s"
    },
    {
      name  = "scrapeSampleLimit"
      value = 1000
    }
  ]

  amp_gitops_config = {
    roleArn            = module.irsa_amp_ingest[0].irsa_iam_role_arn
    ampWorkspaceUrl    = var.amazon_prometheus_workspace_endpoint
    serviceAccountName = local.amazon_prometheus_ingest_service_account
  }

  argocd_gitops_config = merge(
    { enable = true },
    local.amp_gitops_config
  )

}
