locals {
  name                 = "aws-load-balancer-controller"
  service_account_name = "${local.name}-sa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://aws.github.io/eks-charts"
    version     = "1.3.1"
    namespace   = "kube-system"
    timeout     = "1200"
    values      = local.default_helm_values
    description = "aws-load-balancer-controller Helm Chart for ingress resources"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region           = var.addon_context.aws_region_name,
    eks_cluster_id       = var.addon_context.eks_cluster_id,
    service_account_name = local.service_account_name
  })]

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

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }

  irsa_config = {
    kubernetes_namespace              = "kube-system"
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = false
    create_kubernetes_service_account = true
    iam_role_path                     = "/"
    irsa_iam_policies                 = [aws_iam_policy.aws_load_balancer_controller.arn]
    irsa_iam_permissions_boundary     = var.irsa_iam_permissions_boundary
  }
}
