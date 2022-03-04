locals {
  name                 = "traefik"
  service_account_name = "traefik-sa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://helm.traefik.io/traefik"
    version     = "10.14.1"
    namespace   = local.name
    description = "The Traefik HelmChart is focused on Traefik deployment configuration"
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    sa-name = local.service_account_name
  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
