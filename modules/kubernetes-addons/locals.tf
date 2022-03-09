locals {
  # Configuration for managing add-ons via ArgoCD.
  argocd_add_on_config = {
    agones                    = var.enable_agones ? module.agones[0].argocd_gitops_config : null
    awsEfsCsiDriver           = var.enable_aws_efs_csi_driver ? module.aws_efs_csi_driver[0].argocd_gitops_config : null
    awsForFluentBit           = var.enable_aws_for_fluentbit ? module.aws_for_fluent_bit[0].argocd_gitops_config : null
    awsLoadBalancerController = var.enable_aws_load_balancer_controller ? module.aws_load_balancer_controller[0].argocd_gitops_config : null
    certManager               = var.enable_cert_manager ? module.cert_manager[0].argocd_gitops_config : null
    clusterAutoscaler         = var.enable_cluster_autoscaler ? module.cluster_autoscaler[0].argocd_gitops_config : null
    ingressNginx              = var.enable_ingress_nginx ? module.ingress_nginx[0].argocd_gitops_config : null
    keda                      = var.enable_keda ? module.keda[0].argocd_gitops_config : null
    metricsServer             = var.enable_metrics_server ? module.metrics_server[0].argocd_gitops_config : null
    prometheus                = var.enable_prometheus ? module.prometheus[0].argocd_gitops_config : null
    sparkOperator             = var.enable_spark_k8s_operator ? module.spark_k8s_operator[0].argocd_gitops_config : null
    traefik                   = var.enable_traefik ? module.traefik[0].argocd_gitops_config : null
    vpa                       = var.enable_vpa ? module.vpa[0].argocd_gitops_config : null
    yunikorn                  = var.enable_yunikorn ? module.yunikorn[0].argocd_gitops_config : null
    argoRollouts              = var.enable_argo_rollouts ? module.argo_rollouts[0].argocd_gitops_config : null
    crossplane                = var.enable_crossplane ? module.crossplane[0].argocd_gitops_config : null
    karpenter                 = var.enable_karpenter ? module.karpenter[0].argocd_gitops_config : null
    kubernetesDashboard       = var.enable_kubernetes_dashboard ? module.kubernetes_dashboard[0].argocd_gitops_config : null
  }

  eks_oidc_issuer_url = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")

  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = data.aws_eks_cluster.eks_cluster.endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = var.eks_cluster_id
    eks_oidc_issuer_url            = local.eks_oidc_issuer_url
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
    tags                           = var.tags
  }
}
