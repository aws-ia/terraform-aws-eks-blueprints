#-----------------AWS Managed EKS Add-ons----------------------

module "aws_vpc_cni" {
  source = "./aws-vpc-cni"

  count = var.enable_amazon_eks_vpc_cni ? 1 : 0

  enable_ipv6 = var.enable_ipv6
  addon_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.amazon_eks_vpc_cni_config,
  )

  addon_context = local.addon_context
}

module "aws_coredns" {
  source = "./aws-coredns"

  count = var.enable_amazon_eks_coredns || var.enable_self_managed_coredns ? 1 : 0

  addon_context = local.addon_context

  # Amazon EKS CoreDNS addon
  enable_amazon_eks_coredns = var.enable_amazon_eks_coredns
  addon_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.amazon_eks_coredns_config,
  )

  # Self-managed CoreDNS addon via Helm chart
  enable_self_managed_coredns = var.enable_self_managed_coredns
  helm_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.self_managed_coredns_helm_config,
    {
      # Putting after because we don't want users to overwrite this - internal use only
      image_registry = local.amazon_container_image_registry_uris[data.aws_region.current.name]
    }
  )

  # CoreDNS cluster proportioanl autoscaler
  enable_cluster_proportional_autoscaler      = var.enable_coredns_cluster_proportional_autoscaler
  cluster_proportional_autoscaler_helm_config = var.coredns_cluster_proportional_autoscaler_helm_config

  remove_default_coredns_deployment      = var.remove_default_coredns_deployment
  eks_cluster_certificate_authority_data = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

module "aws_kube_proxy" {
  source = "./aws-kube-proxy"

  count = var.enable_amazon_eks_kube_proxy ? 1 : 0

  addon_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.amazon_eks_kube_proxy_config,
  )

  addon_context = local.addon_context
}

module "aws_ebs_csi_driver" {
  source = "./aws-ebs-csi-driver"

  count = var.enable_amazon_eks_aws_ebs_csi_driver || var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0

  # Amazon EKS aws-ebs-csi-driver addon
  enable_amazon_eks_aws_ebs_csi_driver = var.enable_amazon_eks_aws_ebs_csi_driver
  addon_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.amazon_eks_aws_ebs_csi_driver_config,
  )

  addon_context = local.addon_context

  # Self-managed aws-ebs-csi-driver addon via Helm chart
  enable_self_managed_aws_ebs_csi_driver = var.enable_self_managed_aws_ebs_csi_driver
  helm_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.self_managed_aws_ebs_csi_driver_helm_config,
  )
}

#-----------------Kubernetes Add-ons----------------------

module "agones" {
  count                        = var.enable_agones ? 1 : 0
  source                       = "./agones"
  helm_config                  = var.agones_helm_config
  eks_worker_security_group_id = var.eks_worker_security_group_id
  manage_via_gitops            = var.argocd_manage_add_ons
  addon_context                = local.addon_context
}

module "airflow" {
  count         = var.enable_airflow ? 1 : 0
  source        = "./airflow"
  helm_config   = var.airflow_helm_config
  addon_context = local.addon_context
}

module "argocd" {
  count         = var.enable_argocd ? 1 : 0
  source        = "./argocd"
  helm_config   = var.argocd_helm_config
  applications  = var.argocd_applications
  addon_config  = { for k, v in local.argocd_addon_config : k => v if v != null }
  addon_context = local.addon_context
}

module "argo_rollouts" {
  count             = var.enable_argo_rollouts ? 1 : 0
  source            = "./argo-rollouts"
  helm_config       = var.argo_rollouts_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "argo_workflows" {
  count             = var.enable_argo_workflows ? 1 : 0
  source            = "./argo-workflows"
  helm_config       = var.argo_workflows_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "aws_efs_csi_driver" {
  count             = var.enable_aws_efs_csi_driver ? 1 : 0
  source            = "./aws-efs-csi-driver"
  helm_config       = var.aws_efs_csi_driver_helm_config
  irsa_policies     = var.aws_efs_csi_driver_irsa_policies
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "aws_fsx_csi_driver" {
  count             = var.enable_aws_fsx_csi_driver ? 1 : 0
  source            = "./aws-fsx-csi-driver"
  helm_config       = var.aws_fsx_csi_driver_helm_config
  irsa_policies     = var.aws_fsx_csi_driver_irsa_policies
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "aws_for_fluent_bit" {
  count                    = var.enable_aws_for_fluentbit ? 1 : 0
  source                   = "./aws-for-fluentbit"
  helm_config              = var.aws_for_fluentbit_helm_config
  irsa_policies            = var.aws_for_fluentbit_irsa_policies
  create_cw_log_group      = var.aws_for_fluentbit_create_cw_log_group
  cw_log_group_name        = var.aws_for_fluentbit_cw_log_group_name
  cw_log_group_retention   = var.aws_for_fluentbit_cw_log_group_retention
  cw_log_group_kms_key_arn = var.aws_for_fluentbit_cw_log_group_kms_key_arn
  manage_via_gitops        = var.argocd_manage_add_ons
  addon_context            = local.addon_context
}

module "aws_cloudwatch_metrics" {
  count             = var.enable_aws_cloudwatch_metrics ? 1 : 0
  source            = "./aws-cloudwatch-metrics"
  helm_config       = var.aws_cloudwatch_metrics_helm_config
  irsa_policies     = var.aws_cloudwatch_metrics_irsa_policies
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "aws_load_balancer_controller" {
  count             = var.enable_aws_load_balancer_controller ? 1 : 0
  source            = "./aws-load-balancer-controller"
  helm_config       = var.aws_load_balancer_controller_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = merge(local.addon_context, { default_repository = local.amazon_container_image_registry_uris[data.aws_region.current.name] })
}

module "aws_node_termination_handler" {
  count                   = var.enable_aws_node_termination_handler && (length(var.auto_scaling_group_names) > 0 || var.enable_karpenter) ? 1 : 0
  source                  = "./aws-node-termination-handler"
  helm_config             = var.aws_node_termination_handler_helm_config
  manage_via_gitops       = var.argocd_manage_add_ons
  irsa_policies           = var.aws_node_termination_handler_irsa_policies
  autoscaling_group_names = var.auto_scaling_group_names
  addon_context           = local.addon_context
}

module "appmesh_controller" {
  count         = var.enable_appmesh_controller ? 1 : 0
  source        = "./appmesh-controller"
  helm_config   = var.appmesh_helm_config
  irsa_policies = var.appmesh_irsa_policies
  addon_context = local.addon_context
}

module "cert_manager" {
  count                             = var.enable_cert_manager ? 1 : 0
  source                            = "./cert-manager"
  helm_config                       = var.cert_manager_helm_config
  manage_via_gitops                 = var.argocd_manage_add_ons
  irsa_policies                     = var.cert_manager_irsa_policies
  addon_context                     = local.addon_context
  domain_names                      = var.cert_manager_domain_names
  install_letsencrypt_issuers       = var.cert_manager_install_letsencrypt_issuers
  letsencrypt_email                 = var.cert_manager_letsencrypt_email
  kubernetes_svc_image_pull_secrets = var.cert_manager_kubernetes_svc_image_pull_secrets
}

module "cert_manager_csi_driver" {
  count             = var.enable_cert_manager_csi_driver ? 1 : 0
  source            = "./cert-manager-csi-driver"
  helm_config       = var.cert_manager_csi_driver_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "cert_manager_istio_csr" {
  count             = var.enable_cert_manager_istio_csr ? 1 : 0
  source            = "./cert-manager-istio-csr"
  helm_config       = var.cert_manager_istio_csr_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "cluster_autoscaler" {
  source = "./cluster-autoscaler"

  count = var.enable_cluster_autoscaler ? 1 : 0

  eks_cluster_version = local.eks_cluster_version
  helm_config         = var.cluster_autoscaler_helm_config
  manage_via_gitops   = var.argocd_manage_add_ons
  addon_context       = local.addon_context
}

module "coredns_autoscaler" {
  count             = var.enable_amazon_eks_coredns && var.enable_coredns_autoscaler && length(var.coredns_autoscaler_helm_config) > 0 ? 1 : 0
  source            = "./cluster-proportional-autoscaler"
  helm_config       = var.coredns_autoscaler_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "crossplane" {
  count                = var.enable_crossplane ? 1 : 0
  source               = "./crossplane"
  helm_config          = var.crossplane_helm_config
  aws_provider         = var.crossplane_aws_provider
  upbound_aws_provider = var.crossplane_upbound_aws_provider
  jet_aws_provider     = var.crossplane_jet_aws_provider
  kubernetes_provider  = var.crossplane_kubernetes_provider
  helm_provider        = var.crossplane_helm_provider
  addon_context        = local.addon_context
}

module "datadog_operator" {
  source = "./datadog-operator"

  count = var.enable_datadog_operator ? 1 : 0

  helm_config       = var.datadog_operator_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "external_dns" {
  source = "./external-dns"

  count = var.enable_external_dns ? 1 : 0

  helm_config       = var.external_dns_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  irsa_policies     = var.external_dns_irsa_policies
  addon_context     = local.addon_context

  domain_name       = var.eks_cluster_domain
  private_zone      = var.external_dns_private_zone
  route53_zone_arns = var.external_dns_route53_zone_arns
}

module "fargate_fluentbit" {
  count         = var.enable_fargate_fluentbit ? 1 : 0
  source        = "./fargate-fluentbit"
  addon_config  = var.fargate_fluentbit_addon_config
  addon_context = local.addon_context
}

module "grafana" {
  count             = var.enable_grafana ? 1 : 0
  source            = "./grafana"
  helm_config       = var.grafana_helm_config
  irsa_policies     = var.grafana_irsa_policies
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "ingress_nginx" {
  count             = var.enable_ingress_nginx ? 1 : 0
  source            = "./ingress-nginx"
  helm_config       = var.ingress_nginx_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "karpenter" {
  source = "./karpenter"

  count = var.enable_karpenter ? 1 : 0

  helm_config                                 = var.karpenter_helm_config
  irsa_policies                               = var.karpenter_irsa_policies
  node_iam_instance_profile                   = var.karpenter_node_iam_instance_profile
  enable_spot_termination                     = var.karpenter_enable_spot_termination_handling
  manage_via_gitops                           = var.argocd_manage_add_ons
  addon_context                               = local.addon_context
  sqs_queue_managed_sse_enabled               = var.sqs_queue_managed_sse_enabled
  sqs_queue_kms_master_key_id                 = var.sqs_queue_kms_master_key_id
  sqs_queue_kms_data_key_reuse_period_seconds = var.sqs_queue_kms_data_key_reuse_period_seconds
}

module "keda" {
  count             = var.enable_keda ? 1 : 0
  source            = "./keda"
  helm_config       = var.keda_helm_config
  irsa_policies     = var.keda_irsa_policies
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "kubernetes_dashboard" {
  count             = var.enable_kubernetes_dashboard ? 1 : 0
  source            = "./kubernetes-dashboard"
  helm_config       = var.kubernetes_dashboard_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "metrics_server" {
  count             = var.enable_metrics_server ? 1 : 0
  source            = "./metrics-server"
  helm_config       = var.metrics_server_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "kube_state_metrics" {
  count             = var.enable_kube_state_metrics ? 1 : 0
  source            = "./kube-state-metrics"
  helm_config       = var.kube_state_metrics_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "ondat" {
  source  = "ondat/ondat-addon/eksblueprints"
  version = "0.1.2"

  count = var.enable_ondat ? 1 : 0

  helm_config       = var.ondat_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
  irsa_policies     = var.ondat_irsa_policies
  create_cluster    = var.ondat_create_cluster
  etcd_endpoints    = var.ondat_etcd_endpoints
  etcd_ca           = var.ondat_etcd_ca
  etcd_cert         = var.ondat_etcd_cert
  etcd_key          = var.ondat_etcd_key
  admin_username    = var.ondat_admin_username
  admin_password    = var.ondat_admin_password
}

module "kube_prometheus_stack" {
  count             = var.enable_kube_prometheus_stack ? 1 : 0
  source            = "./kube-prometheus-stack"
  helm_config       = var.kube_prometheus_stack_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "portworx" {
  count         = var.enable_portworx ? 1 : 0
  source        = "portworx/portworx-addon/eksblueprints"
  version       = "0.0.6"
  helm_config   = var.portworx_helm_config
  addon_context = local.addon_context
}
module "prometheus" {
  count       = var.enable_prometheus ? 1 : 0
  source      = "./prometheus"
  helm_config = var.prometheus_helm_config
  #AWS Managed Prometheus Workspace
  enable_amazon_prometheus             = var.enable_amazon_prometheus
  amazon_prometheus_workspace_endpoint = var.amazon_prometheus_workspace_endpoint
  manage_via_gitops                    = var.argocd_manage_add_ons
  addon_context                        = local.addon_context
}

module "reloader" {
  count             = var.enable_reloader ? 1 : 0
  source            = "./reloader"
  helm_config       = var.reloader_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "spark_history_server" {
  count             = var.enable_spark_history_server ? 1 : 0
  source            = "./spark-history-server"
  helm_config       = var.spark_history_server_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
  irsa_policies     = var.spark_history_server_irsa_policies
  s3a_path          = var.spark_history_server_s3a_path
}

module "spark_k8s_operator" {
  count             = var.enable_spark_k8s_operator ? 1 : 0
  source            = "./spark-k8s-operator"
  helm_config       = var.spark_k8s_operator_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "strimzi_kafka_operator" {
  count             = var.enable_strimzi_kafka_operator ? 1 : 0
  source            = "./strimzi-kafka-operator"
  helm_config       = var.strimzi_kafka_operator_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "sysdig_agent" {
  source  = "sysdiglabs/sysdig-addon/eksblueprints"
  version = "0.0.3"

  count         = var.enable_sysdig_agent ? 1 : 0
  helm_config   = var.sysdig_agent_helm_config
  addon_context = local.addon_context
}

module "tetrate_istio" {
  # source  = "tetratelabs/tetrate-istio-addon/eksblueprints"
  # version = "0.0.7"

  # TODO - remove local source and revert to remote once
  # https://github.com/tetratelabs/terraform-eksblueprints-tetrate-istio-addon/pull/12  is merged
  source = "./tetrate-istio"

  count = var.enable_tetrate_istio ? 1 : 0

  distribution         = var.tetrate_istio_distribution
  distribution_version = var.tetrate_istio_version
  install_base         = var.tetrate_istio_install_base
  install_cni          = var.tetrate_istio_install_cni
  install_istiod       = var.tetrate_istio_install_istiod
  install_gateway      = var.tetrate_istio_install_gateway
  base_helm_config     = var.tetrate_istio_base_helm_config
  cni_helm_config      = var.tetrate_istio_cni_helm_config
  istiod_helm_config   = var.tetrate_istio_istiod_helm_config
  gateway_helm_config  = var.tetrate_istio_gateway_helm_config
  manage_via_gitops    = var.argocd_manage_add_ons
  addon_context        = local.addon_context
}

module "thanos" {
  count             = var.enable_thanos ? 1 : 0
  source            = "./thanos"
  helm_config       = var.thanos_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
  irsa_policies     = var.thanos_irsa_policies
}

module "traefik" {
  count             = var.enable_traefik ? 1 : 0
  source            = "./traefik"
  helm_config       = var.traefik_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "vault" {
  count = var.enable_vault ? 1 : 0

  # See https://registry.terraform.io/modules/hashicorp/hashicorp-vault-eks-addon/aws/
  source  = "hashicorp/hashicorp-vault-eks-addon/aws"
  version = "1.0.0-rc2"

  helm_config       = var.vault_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
}

module "vpa" {
  count             = var.enable_vpa ? 1 : 0
  source            = "./vpa"
  helm_config       = var.vpa_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "yunikorn" {
  count             = var.enable_yunikorn ? 1 : 0
  source            = "./yunikorn"
  helm_config       = var.yunikorn_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "csi_secrets_store_provider_aws" {
  count             = var.enable_secrets_store_csi_driver_provider_aws ? 1 : 0
  source            = "./csi-secrets-store-provider-aws"
  helm_config       = var.csi_secrets_store_provider_aws_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "secrets_store_csi_driver" {
  count             = var.enable_secrets_store_csi_driver ? 1 : 0
  source            = "./secrets-store-csi-driver"
  helm_config       = var.secrets_store_csi_driver_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "aws_privateca_issuer" {
  count                   = var.enable_aws_privateca_issuer ? 1 : 0
  source                  = "./aws-privateca-issuer"
  helm_config             = var.aws_privateca_issuer_helm_config
  manage_via_gitops       = var.argocd_manage_add_ons
  addon_context           = local.addon_context
  aws_privateca_acmca_arn = var.aws_privateca_acmca_arn
  irsa_policies           = var.aws_privateca_issuer_irsa_policies
}

module "velero" {
  count             = var.enable_velero ? 1 : 0
  source            = "./velero"
  helm_config       = var.velero_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
  irsa_policies     = var.velero_irsa_policies
  backup_s3_bucket  = var.velero_backup_s3_bucket
}

module "opentelemetry_operator" {
  source = "./opentelemetry-operator"

  count = var.enable_amazon_eks_adot || var.enable_opentelemetry_operator ? 1 : 0

  # Amazon EKS ADOT addon
  enable_amazon_eks_adot = var.enable_amazon_eks_adot
  addon_config = merge(
    {
      kubernetes_version = var.eks_cluster_version
    },
    var.amazon_eks_adot_config,
  )

  # Self-managed OpenTelemetry Operator via Helm chart
  enable_opentelemetry_operator = var.enable_opentelemetry_operator
  helm_config                   = var.opentelemetry_operator_helm_config

  addon_context = local.addon_context
}

module "adot_collector_java" {
  source = "./adot-collector-java"

  count = var.enable_adot_collector_java ? 1 : 0

  helm_config   = var.adot_collector_java_helm_config
  addon_context = local.addon_context

  amazon_prometheus_workspace_endpoint = var.amazon_prometheus_workspace_endpoint
  amazon_prometheus_workspace_region   = var.amazon_prometheus_workspace_region

  depends_on = [
    module.opentelemetry_operator
  ]
}

module "adot_collector_haproxy" {
  source = "./adot-collector-haproxy"

  count = var.enable_adot_collector_haproxy ? 1 : 0

  helm_config   = var.adot_collector_haproxy_helm_config
  addon_context = local.addon_context

  amazon_prometheus_workspace_endpoint = var.amazon_prometheus_workspace_endpoint
  amazon_prometheus_workspace_region   = var.amazon_prometheus_workspace_region

  depends_on = [
    module.opentelemetry_operator
  ]
}

module "adot_collector_memcached" {
  source = "./adot-collector-memcached"

  count = var.enable_adot_collector_memcached ? 1 : 0

  helm_config   = var.adot_collector_memcached_helm_config
  addon_context = local.addon_context

  amazon_prometheus_workspace_endpoint = var.amazon_prometheus_workspace_endpoint
  amazon_prometheus_workspace_region   = var.amazon_prometheus_workspace_region

  depends_on = [
    module.opentelemetry_operator
  ]
}

module "adot_collector_nginx" {
  source = "./adot-collector-nginx"

  count = var.enable_adot_collector_nginx ? 1 : 0

  helm_config   = var.adot_collector_nginx_helm_config
  addon_context = local.addon_context

  amazon_prometheus_workspace_endpoint = var.amazon_prometheus_workspace_endpoint
  amazon_prometheus_workspace_region   = var.amazon_prometheus_workspace_region

  depends_on = [
    module.opentelemetry_operator
  ]
}

module "kuberay_operator" {
  source = "./kuberay-operator"

  count = var.enable_kuberay_operator ? 1 : 0

  helm_config   = var.kuberay_operator_helm_config
  addon_context = local.addon_context
}

module "external_secrets" {
  source = "./external-secrets"

  count = var.enable_external_secrets ? 1 : 0

  helm_config                           = var.external_secrets_helm_config
  manage_via_gitops                     = var.argocd_manage_add_ons
  addon_context                         = local.addon_context
  irsa_policies                         = var.external_secrets_irsa_policies
  external_secrets_ssm_parameter_arns   = var.external_secrets_ssm_parameter_arns
  external_secrets_secrets_manager_arns = var.external_secrets_secrets_manager_arns
}

module "promtail" {
  source = "./promtail"

  count = var.enable_promtail ? 1 : 0

  helm_config       = var.promtail_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "calico" {
  source = "./calico"

  count = var.enable_calico ? 1 : 0

  helm_config       = var.calico_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "kubecost" {
  source = "./kubecost"

  count = var.enable_kubecost ? 1 : 0

  helm_config       = var.kubecost_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "kyverno" {
  source = "./kyverno"

  count = var.enable_kyverno ? 1 : 0

  addon_context     = local.addon_context
  manage_via_gitops = var.argocd_manage_add_ons

  kyverno_helm_config = var.kyverno_helm_config

  enable_kyverno_policies      = var.enable_kyverno_policies
  kyverno_policies_helm_config = var.kyverno_policies_helm_config

  enable_kyverno_policy_reporter      = var.enable_kyverno_policy_reporter
  kyverno_policy_reporter_helm_config = var.kyverno_policy_reporter_helm_config
}

module "smb_csi_driver" {
  source = "./smb-csi-driver"

  count = var.enable_smb_csi_driver ? 1 : 0

  helm_config       = var.smb_csi_driver_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "chaos_mesh" {
  source = "./chaos-mesh"

  count = var.enable_chaos_mesh ? 1 : 0

  helm_config       = var.chaos_mesh_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "cilium" {
  source = "./cilium"

  count = var.enable_cilium ? 1 : 0

  helm_config       = var.cilium_helm_config
  enable_wireguard  = var.cilium_enable_wireguard
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "gatekeeper" {
  source = "./gatekeeper"

  count = var.enable_gatekeeper ? 1 : 0

  helm_config       = var.gatekeeper_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

module "local_volume_provisioner" {
  source = "./local-volume-provisioner"

  count = var.enable_local_volume_provisioner ? 1 : 0

  helm_config   = var.local_volume_provisioner_helm_config
  addon_context = local.addon_context
}

module "nvidia_device_plugin" {
  source = "./nvidia-device-plugin"

  count = var.enable_nvidia_device_plugin ? 1 : 0

  helm_config       = var.nvidia_device_plugin_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

# Sample app for demo purposes
module "app_2048" {
  source = "./app-2048"

  count = var.enable_app_2048 ? 1 : 0
}

module "emr_on_eks" {
  source = "./emr-on-eks"

  for_each = { for k, v in var.emr_on_eks_config : k => v if var.enable_emr_on_eks }

  # Kubernetes Namespace + Role/Role Binding
  create_namespace       = try(each.value.create_namespace, true)
  namespace              = try(each.value.namespace, each.value.name, each.key)
  create_kubernetes_role = try(each.value.create_kubernetes_role, true)

  # Job Execution Role
  create_iam_role               = try(each.value.create_iam_role, true)
  oidc_provider_arn             = var.eks_oidc_provider_arn
  s3_bucket_arns                = try(each.value.s3_bucket_arns, ["*"])
  role_name                     = try(each.value.role_name, each.value.name, each.key)
  iam_role_use_name_prefix      = try(each.value.iam_role_use_name_prefix, true)
  iam_role_path                 = try(each.value.iam_role_path, null)
  iam_role_description          = try(each.value.iam_role_description, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, null)
  iam_role_additional_policies  = try(each.value.iam_role_additional_policies, {})

  # Cloudwatch Log Group
  create_cloudwatch_log_group            = try(each.value.create_cloudwatch_log_group, true)
  cloudwatch_log_group_arn               = try(each.value.cloudwatch_log_group_arn, "arn:aws:logs:*:*:*")
  cloudwatch_log_group_retention_in_days = try(each.value.cloudwatch_log_group_retention_in_days, 7)
  cloudwatch_log_group_kms_key_id        = try(each.value.cloudwatch_log_group_kms_key_id, null)

  # EMR Virtual Cluster
  name           = try(each.value.name, each.key)
  eks_cluster_id = data.aws_eks_cluster.eks_cluster.id # Data source is tied to `sleep` to ensure data plane is ready first

  tags = merge(var.tags, try(each.value.tags, {}))
}

module "consul" {
  count             = var.enable_consul ? 1 : 0
  source            = "./consul"
  helm_config       = var.consul_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}
