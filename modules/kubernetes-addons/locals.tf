locals {

  eks_oidc_issuer_url  = var.eks_oidc_provider != null ? var.eks_oidc_provider : replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_cluster_endpoint = var.eks_cluster_endpoint != null ? var.eks_cluster_endpoint : data.aws_eks_cluster.eks_cluster.endpoint
  eks_cluster_version  = var.eks_cluster_version != null ? var.eks_cluster_version : data.aws_eks_cluster.eks_cluster.version

  # Configuration for managing add-ons via ArgoCD.
  argocd_addon_config = {
    agones                    = var.enable_agones ? try(module.agones[0].argocd_gitops_config, null) : null
    awsEfsCsiDriver           = var.enable_aws_efs_csi_driver ? try(module.aws_efs_csi_driver[0].argocd_gitops_config, null) : null
    awsFSxCsiDriver           = var.enable_aws_fsx_csi_driver ? try(module.aws_fsx_csi_driver[0].argocd_gitops_config, null) : null
    awsForFluentBit           = var.enable_aws_for_fluentbit ? try(module.aws_for_fluent_bit[0].argocd_gitops_config, null) : null
    awsLoadBalancerController = var.enable_aws_load_balancer_controller ? try(module.aws_load_balancer_controller[0].argocd_gitops_config, null) : null
    awsNodeTerminationHandler = var.enable_aws_node_termination_handler ? try(module.aws_node_termination_handler[0].argocd_gitops_config, null) : null
    certManager               = var.enable_cert_manager ? try(module.cert_manager[0].argocd_gitops_config, null) : null
    clusterAutoscaler         = var.enable_cluster_autoscaler ? try(module.cluster_autoscaler[0].argocd_gitops_config, null) : null
    corednsAutoscaler         = var.enable_amazon_eks_coredns && var.enable_coredns_autoscaler && length(var.coredns_autoscaler_helm_config) > 0 ? try(module.coredns_autoscaler[0].argocd_gitops_config, null) : null
    datadogOperator           = var.enable_datadog_operator ? try(module.datadog_operator[0].argocd_gitops_config, null) : null
    grafana                   = var.enable_grafana ? try(module.grafana[0].argocd_gitops_config, null) : null
    ingressNginx              = var.enable_ingress_nginx ? try(try(module.ingress_nginx[0].argocd_gitops_config, null), null) : null
    keda                      = var.enable_keda ? try(try(module.keda[0].argocd_gitops_config, null), null) : null
    metricsServer             = var.enable_metrics_server ? try(try(module.metrics_server[0].argocd_gitops_config, null), null) : null
    ondat                     = var.enable_ondat ? try(try(module.ondat[0].argocd_gitops_config, null), null) : null
    prometheus                = var.enable_prometheus ? try(try(module.prometheus[0].argocd_gitops_config, null), null) : null
    sparkHistoryServer        = var.enable_spark_history_server ? try(try(module.spark_history_server[0].argocd_gitops_config, null), null) : null
    sparkOperator             = var.enable_spark_k8s_operator ? try(module.spark_k8s_operator[0].argocd_gitops_config, null) : null
    tetrateIstio              = var.enable_tetrate_istio ? try(module.tetrate_istio[0].argocd_gitops_config, null) : null
    traefik                   = var.enable_traefik ? try(module.traefik[0].argocd_gitops_config, null) : null
    vault                     = var.enable_vault ? try(module.vault[0].argocd_gitops_config, null) : null
    vpa                       = var.enable_vpa ? try(module.vpa[0].argocd_gitops_config, null) : null
    yunikorn                  = var.enable_yunikorn ? try(module.yunikorn[0].argocd_gitops_config, null) : null
    argoRollouts              = var.enable_argo_rollouts ? try(module.argo_rollouts[0].argocd_gitops_config, null) : null
    argoWorkflows             = var.enable_argo_workflows ? try(module.argo_workflows[0].argocd_gitops_config, null) : null
    karpenter                 = var.enable_karpenter ? try(module.karpenter[0].argocd_gitops_config, null) : null
    kubernetesDashboard       = var.enable_kubernetes_dashboard ? try(module.kubernetes_dashboard[0].argocd_gitops_config, null) : null
    kubePrometheusStack       = var.enable_kube_prometheus_stack ? try(module.kube_prometheus_stack[0].argocd_gitops_config, null) : null
    awsCloudWatchMetrics      = var.enable_aws_cloudwatch_metrics ? try(module.aws_cloudwatch_metrics[0].argocd_gitops_config, null) : null
    externalDns               = var.enable_external_dns ? try(module.external_dns[0].argocd_gitops_config, null) : null
    externalSecrets           = var.enable_external_secrets ? try(module.external_secrets[0].argocd_gitops_config, null) : null
    velero                    = var.enable_velero ? try(module.velero[0].argocd_gitops_config, null) : null
    promtail                  = var.enable_promtail ? try(module.promtail[0].argocd_gitops_config, null) : null
    calico                    = var.enable_calico ? try(module.calico[0].argocd_gitops_config, null) : null
    kubecost                  = var.enable_kubecost ? try(module.kubecost[0].argocd_gitops_config, null) : null
    strimziKafkaOperator      = var.enable_strimzi_kafka_operator ? try(module.strimzi_kafka_operator[0].argocd_gitops_config, null) : null
    smb_csi_driver            = var.enable_smb_csi_driver ? try(module.smb_csi_driver[0].argocd_gitops_config, null) : null
    chaos_mesh                = var.enable_chaos_mesh ? try(module.chaos_mesh[0].argocd_gitops_config, null) : null
    cilium                    = var.enable_cilium ? try(module.cilium[0].argocd_gitops_config, null) : null
    gatekeeper                = var.enable_gatekeeper ? try(module.gatekeeper[0].argocd_gitops_config, null) : null
    kyverno                   = var.enable_kyverno ? try({ enable = true }, null) : null
    kyverno_policies          = var.enable_kyverno ? try({ enable = true }, null) : null
    kyverno_policy_reporter   = var.enable_kyverno ? try({ enable = true }, null) : null
    nvidiaDevicePlugin        = var.enable_nvidia_device_plugin ? try(module.nvidia_device_plugin[0].argocd_gitops_config, null) : null
    consul                    = var.enable_consul ? try(module.consul[0].argocd_gitops_config, null) : null
    thanos                    = var.enable_thanos ? try(module.thanos[0].argocd_gitops_config, null) : null
    kubeStateMetrics          = var.enable_kube_state_metrics ? try(module.kube_state_metrics[0].argocd_gitops_config, null) : null
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
