locals {
  # Configuration for managing add-ons via ArgoCD.
  argocd_add_on_config = {
    agones                    = var.enable_agones ? module.agones[0].argocd_gitops_config : null
    awsForFluentBit           = var.enable_aws_for_fluentbit ? module.aws_for_fluent_bit[0].argocd_gitops_config : null
    awsLoadBalancerController = var.enable_aws_load_balancer_controller ? module.aws_load_balancer_controller[0].argocd_gitops_config : null
    awsOtelCollector          = var.enable_aws_open_telemetry ? module.aws_opentelemetry_collector[0].argocd_gitops_config : null
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
  }
}
