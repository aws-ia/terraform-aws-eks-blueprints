variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "eks_cluster_domain" {
  description = "The domain for the EKS cluster"
  type        = string
  default     = ""
}

variable "eks_worker_security_group_id" {
  description = "EKS Worker Security group Id created by EKS module"
  type        = string
  default     = ""
}

variable "auto_scaling_group_names" {
  description = "List of self-managed node groups autoscaling group names"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}

variable "eks_oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  type        = string
  default     = null
}

variable "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
  default     = null
}

variable "eks_cluster_version" {
  description = "The Kubernetes version for the cluster"
  type        = string
  default     = null
}

#-----------EKS MANAGED ADD-ONS------------
variable "enable_ipv6" {
  description = "Enable Ipv6 network. Attaches new VPC CNI policy to the IRSA role"
  type        = bool
  default     = false
}

variable "amazon_eks_vpc_cni_config" {
  description = "ConfigMap of Amazon EKS VPC CNI add-on"
  type        = any
  default     = {}
}

variable "enable_amazon_eks_coredns" {
  description = "Enable Amazon EKS CoreDNS add-on"
  type        = bool
  default     = false
}

variable "amazon_eks_coredns_config" {
  description = "Configuration for Amazon CoreDNS EKS add-on"
  type        = any
  default     = {}
}

variable "enable_self_managed_coredns" {
  description = "Enable self-managed CoreDNS add-on"
  type        = bool
  default     = false
}

variable "self_managed_coredns_helm_config" {
  description = "Self-managed CoreDNS Helm chart config"
  type        = any
  default     = {}
}

variable "amazon_eks_kube_proxy_config" {
  description = "ConfigMap for Amazon EKS Kube-Proxy add-on"
  type        = any
  default     = {}
}

variable "amazon_eks_aws_ebs_csi_driver_config" {
  description = "configMap for AWS EBS CSI Driver add-on"
  type        = any
  default     = {}
}

variable "enable_amazon_eks_vpc_cni" {
  description = "Enable VPC CNI add-on"
  type        = bool
  default     = false
}

variable "enable_amazon_eks_kube_proxy" {
  description = "Enable Kube Proxy add-on"
  type        = bool
  default     = false
}

variable "enable_amazon_eks_aws_ebs_csi_driver" {
  description = "Enable EKS Managed AWS EBS CSI Driver add-on; enable_amazon_eks_aws_ebs_csi_driver and enable_self_managed_aws_ebs_csi_driver are mutually exclusive"
  type        = bool
  default     = false
}

variable "enable_self_managed_aws_ebs_csi_driver" {
  description = "Enable self-managed aws-ebs-csi-driver add-on; enable_self_managed_aws_ebs_csi_driver and enable_amazon_eks_aws_ebs_csi_driver are mutually exclusive"
  type        = bool
  default     = false
}

variable "self_managed_aws_ebs_csi_driver_helm_config" {
  description = "Self-managed aws-ebs-csi-driver Helm chart config"
  type        = any
  default     = {}
}

variable "custom_image_registry_uri" {
  description = "Custom image registry URI map of `{region = dkr.endpoint }`"
  type        = map(string)
  default     = {}
}

#-----------CLUSTER AUTOSCALER-------------
variable "enable_cluster_autoscaler" {
  description = "Enable Cluster autoscaler add-on"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_helm_config" {
  description = "Cluster Autoscaler Helm Chart config"
  type        = any
  default     = {}
}

#-----------COREDNS AUTOSCALER-------------
variable "enable_coredns_autoscaler" {
  description = "Enable CoreDNS autoscaler add-on"
  type        = bool
  default     = false
}

variable "coredns_autoscaler_helm_config" {
  description = "CoreDNS Autoscaler Helm Chart config"
  type        = any
  default     = {}
}

#-----------Crossplane ADDON-------------
variable "enable_crossplane" {
  description = "Enable Crossplane add-on"
  type        = bool
  default     = false
}

variable "crossplane_helm_config" {
  description = "Crossplane Helm Chart config"
  type        = any
  default     = null
}

variable "crossplane_aws_provider" {
  description = "AWS Provider config for Crossplane"
  type = object({
    enable                   = bool
    provider_aws_version     = string
    additional_irsa_policies = list(string)
  })
  default = {
    enable                   = false
    provider_aws_version     = "v0.24.1"
    additional_irsa_policies = []
  }
}

variable "crossplane_jet_aws_provider" {
  description = "AWS Provider Jet AWS config for Crossplane"
  type = object({
    enable                   = bool
    provider_aws_version     = string
    additional_irsa_policies = list(string)
  })
  default = {
    enable                   = false
    provider_aws_version     = "v0.24.1"
    additional_irsa_policies = []
  }
}

#-----------ONDAT ADDON-------------
variable "enable_ondat" {
  description = "Enable Ondat add-on"
  type        = bool
  default     = false
}

variable "ondat_helm_config" {
  description = "Ondat Helm Chart config"
  type        = any
  default     = {}
}

variable "ondat_irsa_policies" {
  description = "IAM policy ARNs for Ondat IRSA"
  type        = list(string)
  default     = []
}

variable "ondat_create_cluster" {
  description = "Create cluster resources"
  type        = bool
  default     = true
}

variable "ondat_etcd_endpoints" {
  description = "List of etcd endpoints for Ondat"
  type        = list(string)
  default     = []
}

variable "ondat_etcd_ca" {
  description = "CA content for Ondat etcd"
  type        = string
  default     = null
}

variable "ondat_etcd_cert" {
  description = "Certificate content for Ondat etcd"
  type        = string
  default     = null
}

variable "ondat_etcd_key" {
  type        = string
  description = "Private key content for Ondat etcd"
  default     = null
  sensitive   = true
}

variable "ondat_admin_username" {
  description = "Username for Ondat admin user"
  type        = string
  default     = "storageos"
}

variable "ondat_admin_password" {
  description = "Password for Ondat admin user"
  type        = string
  default     = "storageos"
  sensitive   = true
}

#-----------External DNS ADDON-------------
variable "enable_external_dns" {
  description = "External DNS add-on"
  type        = bool
  default     = false
}

variable "external_dns_helm_config" {
  description = "External DNS Helm Chart config"
  type        = any
  default     = {}
}

variable "external_dns_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "external_dns_private_zone" {
  type        = bool
  description = "Determines if referenced Route53 zone is private."
  default     = false
}

variable "external_dns_route53_zone_arns" {
  description = "List of Route53 zones ARNs which external-dns will have access to create/manage records"
  type        = list(string)
  default     = []
}

#-----------Amazon Managed Service for Prometheus-------------
variable "enable_amazon_prometheus" {
  description = "Enable AWS Managed Prometheus service"
  type        = bool
  default     = false
}

variable "amazon_prometheus_workspace_endpoint" {
  description = "AWS Managed Prometheus WorkSpace Endpoint"
  type        = string
  default     = null
}

variable "amazon_prometheus_workspace_region" {
  description = "AWS Managed Prometheus WorkSpace Region"
  type        = string
  default     = null
}

#-----------PROMETHEUS-------------
variable "enable_prometheus" {
  description = "Enable Community Prometheus add-on"
  type        = bool
  default     = false
}

variable "prometheus_helm_config" {
  description = "Community Prometheus Helm Chart config"
  type        = any
  default     = {}
}

#-----------KUBE-PROMETHEUS-STACK-------------
variable "enable_kube_prometheus_stack" {
  description = "Enable Community kube-prometheus-stack add-on"
  type        = bool
  default     = false
}

variable "kube_prometheus_stack_helm_config" {
  description = "Community kube-prometheus-stack Helm Chart config"
  type        = any
  default     = {}
}

#-----------METRIC SERVER-------------
variable "enable_metrics_server" {
  description = "Enable metrics server add-on"
  type        = bool
  default     = false
}

variable "metrics_server_helm_config" {
  description = "Metrics Server Helm Chart config"
  type        = any
  default     = {}
}

#-----------TETRATE ISTIO-------------
variable "enable_tetrate_istio" {
  description = "Enable Tetrate Istio add-on"
  type        = bool
  default     = false
}

variable "tetrate_istio_distribution" {
  description = "Istio distribution"
  type        = string
  default     = "TID"
}

variable "tetrate_istio_version" {
  description = "Istio version"
  type        = string
  default     = ""
}

variable "tetrate_istio_install_base" {
  description = "Install Istio `base` Helm Chart"
  type        = bool
  default     = true
}

variable "tetrate_istio_install_cni" {
  description = "Install Istio `cni` Helm Chart"
  type        = bool
  default     = true
}

variable "tetrate_istio_install_istiod" {
  description = "Install Istio `istiod` Helm Chart"
  type        = bool
  default     = true
}

variable "tetrate_istio_install_gateway" {
  description = "Install Istio `gateway` Helm Chart"
  type        = bool
  default     = true
}

variable "tetrate_istio_base_helm_config" {
  description = "Istio `base` Helm Chart config"
  type        = any
  default     = {}
}

variable "tetrate_istio_cni_helm_config" {
  description = "Istio `cni` Helm Chart config"
  type        = any
  default     = {}
}

variable "tetrate_istio_istiod_helm_config" {
  description = "Istio `istiod` Helm Chart config"
  type        = any
  default     = {}
}

variable "tetrate_istio_gateway_helm_config" {
  description = "Istio `gateway` Helm Chart config"
  type        = any
  default     = {}
}

#-----------TRAEFIK-------------
variable "enable_traefik" {
  description = "Enable Traefik add-on"
  type        = bool
  default     = false
}

variable "traefik_helm_config" {
  description = "Traefik Helm Chart config"
  type        = any
  default     = {}
}

#-----------AGONES-------------
variable "enable_agones" {
  description = "Enable Agones GamServer add-on"
  type        = bool
  default     = false
}

variable "agones_helm_config" {
  description = "Agones GameServer Helm Chart config"
  type        = any
  default     = {}
}

#-----------AWS EFS CSI DRIVER ADDON-------------
variable "enable_aws_efs_csi_driver" {
  description = "Enable AWS EFS CSI driver add-on"
  type        = bool
  default     = false
}

variable "aws_efs_csi_driver_helm_config" {
  description = "AWS EFS CSI driver Helm Chart config"
  type        = any
  default     = {}
}

variable "aws_efs_csi_driver_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

#-----------AWS EFS CSI DRIVER ADDON-------------
variable "enable_aws_fsx_csi_driver" {
  description = "Enable AWS FSx CSI driver add-on"
  type        = bool
  default     = false
}

variable "aws_fsx_csi_driver_helm_config" {
  description = "AWS FSx CSI driver Helm Chart config"
  type        = any
  default     = {}
}

variable "aws_fsx_csi_driver_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}
#-----------AWS LB Ingress Controller-------------
variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller add-on"
  type        = bool
  default     = false
}

variable "aws_load_balancer_controller_helm_config" {
  description = "AWS Load Balancer Controller Helm Chart config"
  type        = any
  default     = {}
}

#-----------NGINX-------------
variable "enable_ingress_nginx" {
  description = "Enable Ingress Nginx add-on"
  type        = bool
  default     = false
}

variable "ingress_nginx_helm_config" {
  description = "Ingress Nginx Helm Chart config"
  type        = any
  default     = {}
}

#-----------Spark History Server-------------
variable "enable_spark_history_server" {
  description = "Enable Spark History Server add-on"
  type        = bool
  default     = false
}

variable "spark_history_server_helm_config" {
  description = "Spark History Server Helm Chart config"
  type        = any
  default     = {}
}

variable "spark_history_server_s3a_path" {
  description = "s3a path with prefix for Spark history server e.g., s3a://<bucket_name>/<spark_event_logs>"
  type        = string
  default     = ""
}

variable "spark_history_server_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

#-----------SPARK K8S OPERATOR-------------
variable "enable_spark_k8s_operator" {
  description = "Enable Spark on K8s Operator add-on"
  type        = bool
  default     = false
}

variable "spark_k8s_operator_helm_config" {
  description = "Spark on K8s Operator Helm Chart config"
  type        = any
  default     = {}
}

#-----------AWS FOR FLUENT BIT-------------
variable "enable_aws_for_fluentbit" {
  description = "Enable AWS for FluentBit add-on"
  type        = bool
  default     = false
}

variable "aws_for_fluentbit_helm_config" {
  description = "AWS for FluentBit Helm Chart config"
  type        = any
  default     = {}
}

variable "aws_for_fluentbit_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "aws_for_fluentbit_cw_log_group_name" {
  description = "FluentBit CloudWatch Log group name"
  type        = string
  default     = null
}

variable "aws_for_fluentbit_cw_log_group_retention" {
  description = "FluentBit CloudWatch Log group retention period"
  type        = number
  default     = 90
}

variable "aws_for_fluentbit_cw_log_group_kms_key_arn" {
  description = "FluentBit CloudWatch Log group KMS Key"
  type        = string
  default     = null
}

#-----------AWS CloudWatch Metrics-------------
variable "enable_aws_cloudwatch_metrics" {
  description = "Enable AWS CloudWatch Metrics add-on for Container Insights"
  type        = bool
  default     = false
}

variable "aws_cloudwatch_metrics_helm_config" {
  description = "AWS CloudWatch Metrics Helm Chart config"
  type        = any
  default     = {}
}

variable "aws_cloudwatch_metrics_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

#-----------FARGATE FLUENT BIT-------------
variable "enable_fargate_fluentbit" {
  description = "Enable Fargate FluentBit add-on"
  type        = bool
  default     = false
}

variable "fargate_fluentbit_addon_config" {
  description = "Fargate fluentbit add-on config"
  type        = any
  default     = {}
}

#-----------CERT MANAGER-------------
variable "enable_cert_manager" {
  description = "Enable Cert Manager add-on"
  type        = bool
  default     = false
}

variable "cert_manager_helm_config" {
  description = "Cert Manager Helm Chart config"
  type        = any
  default     = {}
}

variable "cert_manager_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "cert_manager_domain_names" {
  description = "Domain names of the Route53 hosted zone to use with cert-manager"
  type        = list(string)
  default     = []
}

variable "cert_manager_install_letsencrypt_issuers" {
  description = "Install Let's Encrypt Cluster Issuers"
  type        = bool
  default     = true
}

variable "cert_manager_letsencrypt_email" {
  description = "Email address for expiration emails from Let's Encrypt"
  type        = string
  default     = ""
}

#-----------Argo Rollouts ADDON-------------
variable "enable_argo_rollouts" {
  description = "Enable Argo Rollouts add-on"
  type        = bool
  default     = false
}

variable "argo_rollouts_helm_config" {
  description = "Argo Rollouts Helm Chart config"
  type        = any
  default     = null
}

#-----------ARGOCD ADDON-------------
variable "enable_argocd" {
  description = "Enable Argo CD Kubernetes add-on"
  type        = bool
  default     = false
}

variable "argocd_helm_config" {
  description = "Argo CD Kubernetes add-on config"
  type        = any
  default     = {}
}

variable "argocd_applications" {
  description = "Argo CD Applications config to bootstrap the cluster"
  type        = any
  default     = {}
}

variable "argocd_manage_add_ons" {
  description = "Enable managing add-on configuration via ArgoCD App of Apps"
  type        = bool
  default     = false
}

#-----------AWS NODE TERMINATION HANDLER-------------
variable "enable_aws_node_termination_handler" {
  description = "Enable AWS Node Termination Handler add-on"
  type        = bool
  default     = false
}

variable "aws_node_termination_handler_helm_config" {
  description = "AWS Node Termination Handler Helm Chart config"
  type        = any
  default     = {}
}

variable "aws_node_termination_handler_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

#-----------KARPENTER ADDON-------------
variable "enable_karpenter" {
  description = "Enable Karpenter autoscaler add-on"
  type        = bool
  default     = false
}

variable "karpenter_helm_config" {
  description = "Karpenter autoscaler add-on config"
  type        = any
  default     = {}
}

variable "karpenter_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "karpenter_node_iam_instance_profile" {
  description = "Karpenter Node IAM Instance profile id"
  type        = string
  default     = ""
}

#-----------KEDA ADDON-------------
variable "enable_keda" {
  description = "Enable KEDA Event-based autoscaler add-on"
  type        = bool
  default     = false
}

variable "keda_helm_config" {
  description = "KEDA Event-based autoscaler add-on config"
  type        = any
  default     = {}
}

variable "keda_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

#-----------Kubernetes Dashboard ADDON-------------
variable "enable_kubernetes_dashboard" {
  description = "Enable Kubernetes Dashboard add-on"
  type        = bool
  default     = false
}

variable "kubernetes_dashboard_helm_config" {
  description = "Kubernetes Dashboard Helm Chart config"
  type        = any
  default     = null
}

#-----------HashiCorp Vault-------------
variable "enable_vault" {
  description = "Enable HashiCorp Vault add-on"
  type        = bool
  default     = false
}

variable "vault_helm_config" {
  description = "HashiCorp Vault Helm Chart config"
  type        = any
  default     = null
}

#------Vertical Pod Autoscaler(VPA) ADDON--------
variable "enable_vpa" {
  description = "Enable Vertical Pod Autoscaler add-on"
  type        = bool
  default     = false
}

variable "vpa_helm_config" {
  description = "VPA Helm Chart config"
  type        = any
  default     = null
}

#-----------Apache YuniKorn ADDON-------------
variable "enable_yunikorn" {
  description = "Enable Apache YuniKorn K8s scheduler add-on"
  type        = bool
  default     = false
}

variable "yunikorn_helm_config" {
  description = "YuniKorn Helm Chart config"
  type        = any
  default     = null
}

#-----------AWS PCA ISSUER-------------
variable "enable_aws_privateca_issuer" {
  description = "Enable PCA Issuer"
  type        = bool
  default     = false
}

variable "aws_privateca_issuer_helm_config" {
  description = "PCA Issuer Helm Chart config"
  type        = any
  default     = {}
}

variable "aws_privateca_acmca_arn" {
  description = "ARN of AWS ACM PCA"
  type        = string
  default     = ""
}

variable "aws_privateca_issuer_irsa_policies" {
  description = "IAM policy ARNs for AWS ACM PCA IRSA"
  type        = list(string)
  default     = []
}

#-----------OPENTELEMETRY OPERATOR-------------
variable "enable_opentelemetry_operator" {
  description = "Enable opentelemetry operator add-on"
  type        = bool
  default     = false
}

variable "opentelemetry_operator_helm_config" {
  description = "Opentelemetry Operator Helm Chart config"
  type        = any
  default     = {}
}

variable "enable_amazon_eks_adot" {
  description = "Enable Amazon EKS ADOT addon"
  type        = bool
  default     = false
}

variable "amazon_eks_adot_config" {
  description = "Configuration for Amazon EKS ADOT add-on"
  type        = any
  default     = {}
}

#-----------Kubernetes Velero ADDON-------------
variable "enable_velero" {
  description = "Enable Kubernetes Dashboard add-on"
  type        = bool
  default     = false
}

variable "velero_helm_config" {
  description = "Kubernetes Velero Helm Chart config"
  type        = any
  default     = null
}

variable "velero_irsa_policies" {
  description = "IAM policy ARNs for velero IRSA"
  type        = list(string)
  default     = []
}

variable "velero_backup_s3_bucket" {
  description = "Bucket name for velero bucket"
  type        = string
  default     = ""
}

#-----------AWS Observability patterns-------------
variable "enable_adot_collector_java" {
  description = "Enable metrics for JMX workloads"
  type        = bool
  default     = false
}

variable "adot_collector_java_helm_config" {
  description = "ADOT Collector Java Helm Chart config"
  type        = any
  default     = {}
}

variable "enable_adot_collector_haproxy" {
  description = "Enable metrics for HAProxy workloads"
  type        = bool
  default     = false
}

variable "adot_collector_haproxy_helm_config" {
  description = "ADOT Collector HAProxy Helm Chart config"
  type        = any
  default     = {}
}

variable "enable_adot_collector_memcached" {
  description = "Enable metrics for Memcached workloads"
  type        = bool
  default     = false
}

variable "adot_collector_memcached_helm_config" {
  description = "ADOT Collector Memcached Helm Chart config"
  type        = any
  default     = {}
}

variable "enable_adot_collector_nginx" {
  description = "Enable metrics for Nginx workloads"
  type        = bool
  default     = false
}

variable "adot_collector_nginx_helm_config" {
  description = "ADOT Collector Nginx Helm Chart config"
  type        = any
  default     = {}
}

#-----------AWS CSI Secrets Store Provider-------------
variable "enable_secrets_store_csi_driver_provider_aws" {
  type        = bool
  default     = false
  description = "Enable AWS CSI Secrets Store Provider"
}

variable "csi_secrets_store_provider_aws_helm_config" {
  type        = any
  default     = null
  description = "CSI Secrets Store Provider AWS Helm Configurations"
}

#-----------CSI Secrets Store Provider-------------
variable "enable_secrets_store_csi_driver" {
  type        = bool
  default     = false
  description = "Enable CSI Secrets Store Provider"
}

variable "secrets_store_csi_driver_helm_config" {
  type        = any
  default     = null
  description = "CSI Secrets Store Provider Helm Configurations"
}

#-----------EXTERNAL SECRETS OPERATOR-----------
variable "enable_external_secrets" {
  type        = bool
  default     = false
  description = "Enable External Secrets operator add-on"
}

variable "external_secrets_helm_config" {
  type        = any
  default     = {}
  description = "External Secrets operator Helm Chart config"
}

variable "external_secrets_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "external_secrets_ssm_parameter_arns" {
  description = "List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:ssm:*:*:parameter/*"]
}

variable "external_secrets_secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
}

#-----------Grafana ADDON-------------
variable "enable_grafana" {
  description = "Enable Grafana add-on"
  type        = bool
  default     = false
}
variable "grafana_helm_config" {
  description = "Kubernetes Grafana Helm Chart config"
  type        = any
  default     = null
}

variable "grafana_irsa_policies" {
  description = "IAM policy ARNs for grafana IRSA"
  type        = list(string)
  default     = []
}

#-----------KUBERAY OPERATOR-------------
variable "enable_kuberay_operator" {
  description = "Enable KubeRay Operator add-on"
  type        = bool
  default     = false
}

variable "kuberay_operator_helm_config" {
  description = "KubeRay Operator Helm Chart config"
  type        = any
  default     = {}
}

#-----------Apache Airflow ADDON-------------
variable "enable_airflow" {
  description = "Enable Airflow add-on"
  type        = bool
  default     = false
}

variable "airflow_helm_config" {
  description = "Apache Airflow v2 Helm Chart config"
  type        = any
  default     = {}
}

#-----------Promtail ADDON-------------
variable "enable_promtail" {
  description = "Enable Promtail add-on"
  type        = bool
  default     = false
}

variable "promtail_helm_config" {
  description = "Promtail Helm Chart config"
  type        = any
  default     = {}
}

#-----------Calico ADDON-------------
variable "enable_calico" {
  description = "Enable Calico add-on"
  type        = bool
  default     = false
}

variable "calico_helm_config" {
  description = "Calico add-on config"
  type        = any
  default     = {}
}

#-----------Kubecost ADDON-------------
variable "enable_kubecost" {
  description = "Enable Kubecost add-on"
  type        = bool
  default     = false
}

variable "kubecost_helm_config" {
  description = "Kubecost Helm Chart config"
  type        = any
  default     = {}
}
