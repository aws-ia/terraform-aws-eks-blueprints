locals {
  helm_config = {
    name          = "opentelemetry"
    repository    = "https://open-telemetry.github.io/opentelemetry-helm-charts"
    chart         = "opentelemetry-operator"
    version       = "0.6.6"
    namespace     = "opentelemetry-operator-system"
    timeout       = "1200"
    description   = "ADOT Operator helm chart"
    lint          = false
    values        = []
    set           = []
    set_sensitive = null
  }

  argocd_gitops_config = { enable = true }
}
