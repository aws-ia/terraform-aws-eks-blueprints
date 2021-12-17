
locals {

  eks_cluster_id = data.aws_eks_cluster.cluster.id

  # Configuration for managing add-ons via ArgoCD.
  argocd_add_on_config = {
    agones                    = var.agones_enable ? module.agones[0].argocd_gitops_config : null
    awsForFluentBit           = var.aws_for_fluentbit_enable ? module.aws_for_fluent_bit[0].argocd_gitops_config : null
    awsLoadBalancerController = var.aws_lb_ingress_controller_enable ? module.aws_load_balancer_controller[0].argocd_gitops_config : null
    awsOtelCollector          = var.aws_open_telemetry_enable ? module.aws_opentelemetry_collector[0].argocd_gitops_config : null
    certManager               = var.cert_manager_enable ? module.cert_manager[0].argocd_gitops_config : null
    clusterAutoscaler         = var.cluster_autoscaler_enable ? module.cluster_autoscaler[0].argocd_gitops_config : null
    ingressNginx              = var.ingress_nginx_controller_enable ? module.ingress_nginx[0].argocd_gitops_config : null
    keda                      = var.keda_enable ? module.keda[0].argocd_gitops_config : null
    metricsServer             = var.metrics_server_enable ? module.metrics_server[0].argocd_gitops_config : null
    nginxIngress              = var.ingress_nginx_controller_enable ? module.ingress_nginx[0].argocd_gitops_config : null
    prometheus                = var.prometheus_enable ? module.prometheus[0].argocd_gitops_config : null
    sparkOperator             = var.spark_on_k8s_operator_enable ? module.spark_k8s_operator[0].argocd_gitops_config : null
    traefik                   = var.traefik_ingress_controller_enable ? module.traefik_ingress[0].argocd_gitops_config : null
    yunikorn                  = var.yunikorn_enable ? module.yunikorn[0].argocd_gitops_config : null
  }

}
