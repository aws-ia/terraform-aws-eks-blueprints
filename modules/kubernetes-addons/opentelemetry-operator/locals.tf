locals {
  name                       = "adot"
  eks_addon_role_name        = "eks:addon-manager"
  eks_addon_clusterrole_name = "eks:addon-manager-otel"
  addon_namespace            = "opentelemetry-operator-system"

  create_namespace = var.enable_opentelemetry_operator ? true : try(var.helm_config.create_namespace, true)
  namespace        = local.create_namespace ? kubernetes_namespace_v1.adot[0].metadata[0].name : try(var.helm_config.namespace, local.addon_namespace)

  # https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-operator/Chart.yaml
  default_helm_config = {
    name        = "opentelemetry"
    repository  = "https://open-telemetry.github.io/opentelemetry-helm-charts"
    chart       = "opentelemetry-operator"
    version     = "0.16.0"
    namespace   = local.namespace
    description = "ADOT Operator helm chart"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )
}
