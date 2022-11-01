locals {
  name                 = "karpenter"
  service_account_name = "karpenter"
  set_values = [{
    name  = "serviceAccount.name"
    value = local.service_account_name
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  # https://github.com/aws/karpenter/blob/main/charts/karpenter/Chart.yaml
  helm_config = merge(
    {
      name       = local.name
      chart      = local.name
      repository = "oci://public.ecr.aws/karpenter"
      version    = "v0.18.1"
      namespace  = local.name
      values = [
        <<-EOT
          clusterName: ${var.addon_context.eks_cluster_id}
          clusterEndpoint: ${var.addon_context.aws_eks_cluster_endpoint}
          aws:
            defaultInstanceProfile: ${var.node_iam_instance_profile}
        EOT
      ]
      description = "karpenter Helm Chart for Node Autoscaling"
    },
    var.helm_config
  )

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.karpenter.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable                    = true
    serviceAccountName        = local.service_account_name
    controllerClusterEndpoint = var.addon_context.aws_eks_cluster_endpoint
    awsDefaultInstanceProfile = var.node_iam_instance_profile
  }
}
