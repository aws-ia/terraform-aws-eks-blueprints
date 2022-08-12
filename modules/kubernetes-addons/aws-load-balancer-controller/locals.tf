locals {
  name                 = "aws-load-balancer-controller"
  service_account_name = "${local.name}-sa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://aws.github.io/eks-charts"
    version     = "1.4.3"
    namespace   = "kube-system"
    timeout     = "1200"
    values      = local.default_helm_values
    description = "aws-load-balancer-controller Helm Chart for ingress resources"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region           = var.addon_context.aws_region_name,
    eks_cluster_id       = var.addon_context.eks_cluster_id,
    repository           = "${var.addon_context.default_repository}/amazon/aws-load-balancer-controller",
    service_account_name = local.service_account_name,
  })]

  set_values = concat(
    [
      {
        name  = "serviceAccount.name"
        value = local.service_account_name
      },
      {
        name  = "serviceAccount.create"
        value = false
      }
    ],
    try(var.helm_config.set_values, [])
  )

  helm_config = merge(local.default_helm_config, var.helm_config, {
    values : concat(local.default_helm_config["values"], lookup(var.helm_config, "values", []))
  })

  decoded_yaml_values  = [for value in local.helm_config["values"] : yamldecode(value)]
  argocd_gitops_config = yamldecode(data.merge_merge.helm_values.output)

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = [aws_iam_policy.aws_load_balancer_controller.arn]
  }
}

data "merge_merge" "helm_values" {
  dynamic "input" {
    for_each = toset(local.helm_config["values"])
    content {
      format = "yaml"
      data   = input.value
    }
  }

  input {
    format = "yaml"
    data   = yamlencode({ enable = true })
  }

  output_format = "yaml"
}
