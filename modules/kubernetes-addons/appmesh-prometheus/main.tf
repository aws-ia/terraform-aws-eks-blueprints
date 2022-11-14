locals {
  name             = try(var.helm_config.name, "appmesh-prometheus")
  namespace_name   = try(var.helm_config.namespace, "appmesh-system")
  create_namespace = try(var.helm_config.create_namespace, false) && local.namespace_name != "kube-system"

  service_account_name = "${local.name}-sa"

  # `namespace_name` is just the string representation of the namespace name
  # `namespace` is the name of the resultant namespace to use - created or not
  namespace = local.create_namespace ? kubernetes_namespace_v1.prometheus[0].metadata[0].name : local.namespace_name

  default_helm_config = {
    name        = "${local.name}2"
    chart       = local.name
    repository  = "https://aws.github.io/eks-charts"
    namespace   = local.namespace_name
    description = "App Mesh Prometheus helm Chart deployment configuration"
    values = [templatefile("${path.module}/values.yaml", {
      operating_system = try(var.helm_config.operating_system, "linux")
    })]
    version     = "1.0.1"
  }

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
      value = truegit 
    }
  ]

  appmesh_prometheus_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }

  # irsa_config = {
  #   kubernetes_namespace              = local.helm_config["namespace"]
  #   kubernetes_service_account        = local.service_account_name
  #   create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
  #   create_kubernetes_service_account = true
  #   irsa_iam_policies                 = concat([aws_iam_policy.aws_for_fluent_bit.arn], var.irsa_policies)
  # }
}

module "helm_addon" {
  source = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  #irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "kubernetes_namespace_v1" "prometheus" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name = local.namespace_name
  }
}