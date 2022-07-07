locals {
  name                 = "external-dns"
  service_account_name = "${local.name}-sa"
  zone_filter_ids      = jsonencode([data.aws_route53_zone.selected.zone_id])

  default_helm_config = {
    description = "ExternalDNS Helm Chart"
    name        = local.name
    chart       = local.name
    repository  = "https://charts.bitnami.com/bitnami"
    version     = "6.5.6"
    namespace   = local.name
    values      = local.default_helm_values
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region      = var.addon_context.aws_region_name
    zone_filter_ids = local.zone_filter_ids
  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.external_dns.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable             = true
    zoneIdFilter       = data.aws_route53_zone.selected.zone_id
    serviceAccountName = local.service_account_name
  }
}
