locals {
  name                 = "karpenter"
  service_account_name = "karpenter"
  eks_cluster_endpoint = var.addon_context.aws_eks_cluster_endpoint

  set_values = [{
    name  = "serviceAccount.name"
    value = local.service_account_name
    },
    {
      name  = "serviceAccount.create"
      value = false
    },
    {
      name  = "controller.clusterName"
      value = var.addon_context.eks_cluster_id
    },
    {
      name  = "controller.clusterEndpoint"
      value = local.eks_cluster_endpoint
    },
    {
      name  = "aws.defaultInstanceProfile"
      value = var.node_iam_instance_profile
    }
  ]

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://charts.karpenter.sh"
    version     = "0.6.5"
    namespace   = local.name
    timeout     = "300"
    values      = local.default_helm_values
    set         = []
    description = "karpenter Helm Chart for Node Autoscaling"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.karpenter.arn], var.irsa_policies)
    irsa_iam_permissions_boundary     = var.irsa_iam_permissions_boundary
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    eks_cluster_id            = var.addon_context.eks_cluster_id,
    eks_cluster_endpoint      = local.eks_cluster_endpoint,
    service_account_name      = local.service_account_name,
    node_iam_instance_profile = var.node_iam_instance_profile,
    operating_system          = "linux"
  })]

  argocd_gitops_config = {
    enable                    = true
    serviceAccountName        = local.service_account_name
    controllerClusterName     = var.addon_context.eks_cluster_id
    controllerClusterEndpoint = local.eks_cluster_endpoint
    awsDefaultInstanceProfile = var.node_iam_instance_profile
  }
}
