locals {
  default_helm_config = {
    name        = "opentelemetry"
    repository  = "https://open-telemetry.github.io/opentelemetry-helm-charts"
    chart       = "opentelemetry-operator"
    version     = "0.6.6"
    namespace   = "opentelemetry-operator-system"
    timeout     = "1200"
    description = "ADOT Operator helm chart"
    values      = []
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )
}
