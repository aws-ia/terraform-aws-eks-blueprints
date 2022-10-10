locals {
  name = "nops-k8s-agent"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://nops-io.github.io/nops-k8s-agent"
    namespace   = local.name
    values      = local.default_helm_values
    description = "nops-k8s-agent Helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    operating_system = "linux"
    region           = var.addon_context.aws_region_name,
    app_nops_k8s_collector_api_key = var.app_nops_k8s_collector_api_key,
    app_nops_k8s_collector_aws_account_number = var.app_nops_k8s_collector_aws_account_number
    app_prometheus_server_endpoint = var.app_prometheus_server_endpoint
    app_nops_k8s_agent_clusterid  = var.app_nops_k8s_agent_clusterid
    app_nops_k8s_collector_skip_ssl = var.app_nops_k8s_collector_skip_ssl
    app_nops_k8s_agent_prom_token = var.app_nops_k8s_agent_prom_token
    
      })]

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.name
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.nops-k8s-agent.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.name
  }
}