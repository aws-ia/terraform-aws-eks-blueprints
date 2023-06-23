locals {
  name            = "aws-load-balancer-controller"
  service_account = try(var.helm_config.service_account, "${local.name}-sa")

  # https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/Chart.yaml
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://aws.github.io/eks-charts"
    version     = "1.4.5"
    namespace   = "kube-system"
    values      = local.default_helm_values
    description = "aws-load-balancer-controller Helm Chart for ingress resources"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region     = var.addon_context.aws_region_name,
    eks_cluster_id = var.addon_context.eks_cluster_id,
    repository     = "${var.addon_context.default_repository}/amazon/aws-load-balancer-controller"
  })]

  set_values = concat(
    [
      {
        name  = "serviceAccount.name"
        value = local.service_account
      },
      {
        name  = "serviceAccount.create"
        value = false
      }
    ],
    try(var.helm_config.set_values, [])
  )

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account
  }

  irsa_config = {
    kubernetes_namespace                = local.helm_config["namespace"]
    kubernetes_service_account          = local.service_account
    create_kubernetes_namespace         = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(local.helm_config["create_service_account_secret_token"], false)
    irsa_iam_policies                   = [aws_iam_policy.aws_load_balancer_controller.arn]
  }
}
