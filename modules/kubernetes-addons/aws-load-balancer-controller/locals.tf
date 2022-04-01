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
    service_account_name = local.service_account_name,
    ecr_registry         = local.ecr_registry[var.addon_context.aws_region_name]
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
    irsa_iam_policies                 = [aws_iam_policy.aws_load_balancer_controller.arn]
  }

  # each region pulls container images from its own registry
  # for more information see: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  ecr_registry = {
    af-south-1     = "877085696533.dkr.ecr.af-south-1.amazonaws.com",
    ap-east-1      = "800184023465.dkr.ecr.ap-east-1.amazonaws.com",
    ap-northeast-1 = "602401143452.dkr.ecr.ap-northeast-1.amazonaws.com",
    ap-northeast-2 = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com",
    ap-northeast-3 = "602401143452.dkr.ecr.ap-northeast-3.amazonaws.com",
    ap-south-1     = "602401143452.dkr.ecr.ap-south-1.amazonaws.com",
    ap-southeast-1 = "602401143452.dkr.ecr.ap-southeast-1.amazonaws.com",
    ap-southeast-2 = "602401143452.dkr.ecr.ap-southeast-2.amazonaws.com",
    ca-central-1   = "602401143452.dkr.ecr.ca-central-1.amazonaws.com",
    cn-north-1     = "918309763551.dkr.ecr.cn-north-1.amazonaws.com.cn",
    cn-northwest-1 = "961992271922.dkr.ecr.cn-northwest-1.amazonaws.com.cn",
    eu-central-1   = "602401143452.dkr.ecr.eu-central-1.amazonaws.com",
    eu-north-1     = "602401143452.dkr.ecr.eu-north-1.amazonaws.com",
    eu-south-1     = "590381155156.dkr.ecr.eu-south-1.amazonaws.com",
    eu-west-1      = "602401143452.dkr.ecr.eu-west-1.amazonaws.com",
    eu-west-2      = "602401143452.dkr.ecr.eu-west-2.amazonaws.com",
    eu-west-3      = "602401143452.dkr.ecr.eu-west-3.amazonaws.com",
    me-south-1     = "558608220178.dkr.ecr.me-south-1.amazonaws.com",
    sa-east-1      = "602401143452.dkr.ecr.sa-east-1.amazonaws.com",
    us-east-1      = "602401143452.dkr.ecr.us-east-1.amazonaws.com",
    us-east-2      = "602401143452.dkr.ecr.us-east-2.amazonaws.com",
    us-gov-east-1  = "151742754352.dkr.ecr.us-gov-east-1.amazonaws.com",
    us-gov-west-1  = "013241004608.dkr.ecr.us-gov-west-1.amazonaws.com",
    us-west-1      = "602401143452.dkr.ecr.us-west-1.amazonaws.com",
    us-west-2      = "602401143452.dkr.ecr.us-west-2.amazonaws.com"
  }
}
