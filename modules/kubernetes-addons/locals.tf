locals {

  eks_oidc_issuer_url  = var.eks_oidc_provider != null ? var.eks_oidc_provider : replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_cluster_endpoint = var.eks_cluster_endpoint != null ? var.eks_cluster_endpoint : data.aws_eks_cluster.eks_cluster.endpoint
  eks_cluster_version  = var.eks_cluster_version != null ? var.eks_cluster_version : data.aws_eks_cluster.eks_cluster.version

  # Configuration for managing add-ons via ArgoCD.
  argocd_addon_config = {
    agones                    = var.enable_agones ? module.agones[0].argocd_gitops_config : null
    awsEfsCsiDriver           = var.enable_aws_efs_csi_driver ? module.aws_efs_csi_driver[0].argocd_gitops_config : null
    awsFSxCsiDriver           = var.enable_aws_fsx_csi_driver ? module.aws_fsx_csi_driver[0].argocd_gitops_config : null
    awsForFluentBit           = var.enable_aws_for_fluentbit ? module.aws_for_fluent_bit[0].argocd_gitops_config : null
    awsLoadBalancerController = var.enable_aws_load_balancer_controller ? module.aws_load_balancer_controller[0].argocd_gitops_config : null
    awsNodeTerminationHandler = var.enable_aws_node_termination_handler ? module.aws_node_termination_handler[0].argocd_gitops_config : null
    certManager               = var.enable_cert_manager ? module.cert_manager[0].argocd_gitops_config : null
    clusterAutoscaler         = var.enable_cluster_autoscaler ? module.cluster_autoscaler[0].argocd_gitops_config : null
    corednsAutoscaler         = var.enable_amazon_eks_coredns && var.enable_coredns_autoscaler && length(var.coredns_autoscaler_helm_config) > 0 ? module.coredns_autoscaler[0].argocd_gitops_config : null
    datadogOperator           = var.enable_datadog_operator ? module.datadog_operator[0].argocd_gitops_config : null
    grafana                   = var.enable_grafana ? module.grafana[0].argocd_gitops_config : null
    ingressNginx              = var.enable_ingress_nginx ? module.ingress_nginx[0].argocd_gitops_config : null
    keda                      = var.enable_keda ? module.keda[0].argocd_gitops_config : null
    metricsServer             = var.enable_metrics_server ? module.metrics_server[0].argocd_gitops_config : null
    ondat                     = var.enable_ondat ? module.ondat[0].argocd_gitops_config : null
    prometheus                = var.enable_prometheus ? module.prometheus[0].argocd_gitops_config : null
    sparkHistoryServer        = var.enable_spark_history_server ? module.spark_history_server[0].argocd_gitops_config : null
    sparkOperator             = var.enable_spark_k8s_operator ? module.spark_k8s_operator[0].argocd_gitops_config : null
    tetrateIstio              = var.enable_tetrate_istio ? module.tetrate_istio[0].argocd_gitops_config : null
    traefik                   = var.enable_traefik ? module.traefik[0].argocd_gitops_config : null
    vault                     = var.enable_vault ? module.vault[0].argocd_gitops_config : null
    vpa                       = var.enable_vpa ? module.vpa[0].argocd_gitops_config : null
    yunikorn                  = var.enable_yunikorn ? module.yunikorn[0].argocd_gitops_config : null
    argoRollouts              = var.enable_argo_rollouts ? module.argo_rollouts[0].argocd_gitops_config : null
    argoWorkflows             = var.enable_argo_workflows ? module.argo_workflows[0].argocd_gitops_config : null
    karpenter                 = var.enable_karpenter ? module.karpenter[0].argocd_gitops_config : null
    kubernetesDashboard       = var.enable_kubernetes_dashboard ? module.kubernetes_dashboard[0].argocd_gitops_config : null
    kubePrometheusStack       = var.enable_kube_prometheus_stack ? module.kube_prometheus_stack[0].argocd_gitops_config : null
    awsCloudWatchMetrics      = var.enable_aws_cloudwatch_metrics ? module.aws_cloudwatch_metrics[0].argocd_gitops_config : null
    externalDns               = var.enable_external_dns ? module.external_dns[0].argocd_gitops_config : null
    externalSecrets           = var.enable_external_secrets ? module.external_secrets[0].argocd_gitops_config : null
    velero                    = var.enable_velero ? module.velero[0].argocd_gitops_config : null
    promtail                  = var.enable_promtail ? module.promtail[0].argocd_gitops_config : null
    calico                    = var.enable_calico ? module.calico[0].argocd_gitops_config : null
    kubecost                  = var.enable_kubecost ? module.kubecost[0].argocd_gitops_config : null
    strimziKafkaOperator      = var.enable_strimzi_kafka_operator ? module.strimzi_kafka_operator[0].argocd_gitops_config : null
    smb_csi_driver            = var.enable_smb_csi_driver ? module.smb_csi_driver[0].argocd_gitops_config : null
    chaos_mesh                = var.enable_chaos_mesh ? module.chaos_mesh[0].argocd_gitops_config : null
    cilium                    = var.enable_cilium ? module.cilium[0].argocd_gitops_config : null
    gatekeeper                = var.enable_gatekeeper ? module.gatekeeper[0].argocd_gitops_config : null
    kyverno                   = var.enable_kyverno ? { enable = true } : null
    kyverno_policies          = var.enable_kyverno ? { enable = true } : null
    kyverno_policy_reporter   = var.enable_kyverno ? { enable = true } : null
    nvidiaDevicePlugin        = var.enable_nvidia_device_plugin ? module.nvidia_device_plugin[0].argocd_gitops_config : null
    consul                    = var.enable_consul ? module.consul[0].argocd_gitops_config : null
    thanos                    = var.enable_thanos ? module.thanos[0].argocd_gitops_config : null
    kubeStateMetrics          = var.enable_kube_state_metrics ? module.kube_state_metrics[0].argocd_gitops_config : null
  }

  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = local.eks_cluster_endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = data.aws_eks_cluster.eks_cluster.id
    eks_oidc_issuer_url            = local.eks_oidc_issuer_url
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
    tags                           = var.tags
    irsa_iam_role_path             = var.irsa_iam_role_path
    irsa_iam_permissions_boundary  = var.irsa_iam_permissions_boundary
  }

  # For addons that pull images from a region-specific ECR container registry by default
  # for more information see: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  amazon_container_image_registry_uris = merge(
    {
      af-south-1     = "877085696533.dkr.ecr.af-south-1.amazonaws.com",
      ap-east-1      = "800184023465.dkr.ecr.ap-east-1.amazonaws.com",
      ap-northeast-1 = "602401143452.dkr.ecr.ap-northeast-1.amazonaws.com",
      ap-northeast-2 = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com",
      ap-northeast-3 = "602401143452.dkr.ecr.ap-northeast-3.amazonaws.com",
      ap-south-1     = "602401143452.dkr.ecr.ap-south-1.amazonaws.com",
      ap-south-2     = "900889452093.dkr.ecr.ap-south-2.amazonaws.com",
      ap-southeast-1 = "602401143452.dkr.ecr.ap-southeast-1.amazonaws.com",
      ap-southeast-2 = "602401143452.dkr.ecr.ap-southeast-2.amazonaws.com",
      ap-southeast-3 = "296578399912.dkr.ecr.ap-southeast-3.amazonaws.com",
      ap-southeast-4 = "491585149902.dkr.ecr.ap-southeast-4.amazonaws.com",
      ca-central-1   = "602401143452.dkr.ecr.ca-central-1.amazonaws.com",
      cn-north-1     = "918309763551.dkr.ecr.cn-north-1.amazonaws.com.cn",
      cn-northwest-1 = "961992271922.dkr.ecr.cn-northwest-1.amazonaws.com.cn",
      eu-central-1   = "602401143452.dkr.ecr.eu-central-1.amazonaws.com",
      eu-central-2   = "900612956339.dkr.ecr.eu-central-2.amazonaws.com",
      eu-north-1     = "602401143452.dkr.ecr.eu-north-1.amazonaws.com",
      eu-south-1     = "590381155156.dkr.ecr.eu-south-1.amazonaws.com",
      eu-south-2     = "455263428931.dkr.ecr.eu-south-2.amazonaws.com",
      eu-west-1      = "602401143452.dkr.ecr.eu-west-1.amazonaws.com",
      eu-west-2      = "602401143452.dkr.ecr.eu-west-2.amazonaws.com",
      eu-west-3      = "602401143452.dkr.ecr.eu-west-3.amazonaws.com",
      me-south-1     = "558608220178.dkr.ecr.me-south-1.amazonaws.com",
      me-central-1   = "759879836304.dkr.ecr.me-central-1.amazonaws.com",
      sa-east-1      = "602401143452.dkr.ecr.sa-east-1.amazonaws.com",
      us-east-1      = "602401143452.dkr.ecr.us-east-1.amazonaws.com",
      us-east-2      = "602401143452.dkr.ecr.us-east-2.amazonaws.com",
      us-gov-east-1  = "151742754352.dkr.ecr.us-gov-east-1.amazonaws.com",
      us-gov-west-1  = "013241004608.dkr.ecr.us-gov-west-1.amazonaws.com",
      us-west-1      = "602401143452.dkr.ecr.us-west-1.amazonaws.com",
      us-west-2      = "602401143452.dkr.ecr.us-west-2.amazonaws.com"
    },
    var.custom_image_registry_uri
  )
}
