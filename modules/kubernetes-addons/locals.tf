
locals {
  # Configuration for managing add-ons via ArgoCD.
  argocd_add_on_config = {
    agones                    = var.enable_agones ? module.agones[0].argocd_gitops_config : {}
    awsForFluentBit           = var.enable_aws_for_fluentbit ? module.aws_for_fluent_bit[0].argocd_gitops_config : {}
    awsLoadBalancerController = var.enable_aws_load_balancer_controller ? module.aws_load_balancer_controller[0].argocd_gitops_config : {}
    awsOtelCollector          = var.enable_aws_open_telemetry ? module.aws_opentelemetry_collector[0].argocd_gitops_config : {}
    certManager               = var.enable_cert_manager ? module.cert_manager[0].argocd_gitops_config : {}
    clusterAutoscaler         = var.enable_cluster_autoscaler ? module.cluster_autoscaler[0].argocd_gitops_config : {}
    ingressNginx              = var.enable_ingress_nginx ? module.ingress_nginx[0].argocd_gitops_config : {}
    keda                      = var.enable_keda ? module.keda[0].argocd_gitops_config : {}
    metricsServer             = var.enable_metrics_server ? module.metrics_server[0].argocd_gitops_config : {}
    prometheus                = var.enable_prometheus ? module.prometheus[0].argocd_gitops_config : {}
    sparkOperator             = var.enable_spark_k8s_operator ? module.spark_k8s_operator[0].argocd_gitops_config : {}
    traefik                   = var.enable_traefik ? module.traefik[0].argocd_gitops_config : {}
    yunikorn                  = var.enable_yunikorn ? module.yunikorn[0].argocd_gitops_config : {}
  }
}
