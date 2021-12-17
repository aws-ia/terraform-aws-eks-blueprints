variable "eks_cluster_id" {
  description = "EKS Cluster ID"
}

variable "eks_worker_security_group_id" {
  description = "EKS Worker Security group ID created by EKS module"
  default       = ""
}

variable "eks_cluster_oidc_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  default       = ""
}

variable "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  default       = ""
}

variable "auto_scaling_group_names" {
  description = "List of Self Managed Node Groups Autoscaling group names"
  default     = []
}

variable "node_groups_iam_role_arn" {
  type    = list(string)
  default = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}
#-----------EKS MANAGED ADD-ONS------------
# EKS MANAGED ADDONS
variable "eks_addon_vpc_cni_config" {
  description = "Map of Amazon EKS VPC CNI Add-on"
  type        = any
  default     = {}
}

variable "eks_addon_coredns_config" {
  description = "Map of Amazon COREDNS EKS Add-on"
  type        = any
  default     = {}
}

variable "eks_addon_kube_proxy_config" {
  description = "Map of Amazon EKS KUBE_PROXY Add-on"
  type        = any
  default     = {}
}

variable "eks_addon_aws_ebs_csi_driver_config" {
  description = "Map of Amazon EKS aws_ebs_csi_driver Add-on"
  type        = any
  default     = {}
}

variable "enable_eks_addon_vpc_cni" {
  type        = bool
  default     = false
  description = "Enable VPC CNI Addon"
}

variable "enable_eks_addon_coredns" {
  type        = bool
  default     = false
  description = "Enable CoreDNS Addon"
}

variable "enable_eks_addon_kube_proxy" {
  type        = bool
  default     = false
  description = "Enable Kube Proxy Addon"
}

variable "enable_eks_addon_aws_ebs_csi_driver" {
  type        = bool
  default     = false
  description = "Enable EKS Managed EBS CSI Driver Addon"
}
#-----------CLUSTER AUTOSCALER-------------
variable "cluster_autoscaler_enable" {
  type        = bool
  default     = false
  description = "Enabling Cluster autoscaler on eks cluster"
}

variable "cluster_autoscaler_helm_chart" {
  type        = any
  default     = {}
  description = "Cluster Autoscaler Helm Chart Config"
}

#-----------PROMETHEUS-------------
variable "aws_managed_prometheus_enable" {
  type        = bool
  default     = false
  description = "Enable AWS Managed Prometheus service"
}

variable "aws_managed_prometheus_workspace_id" {
  type        = string
  default     = ""
  description = "AWS Managed Prometheus WorkSpace Name"
}

variable "aws_managed_prometheus_ingest_iam_role_arn" {
  type        = string
  default     = ""
  description = "AWS Managed Prometheus WorkSpaceSpace IAM role ARN"
}

variable "aws_managed_prometheus_ingest_service_account" {
  type        = string
  default     = ""
  description = "AWS Managed Prometheus Ingest Service Account"
}

variable "prometheus_enable" {
  description = "Enable Community Prometheus Helm Addon"
  type        = bool
  default     = false
}

variable "prometheus_helm_chart" {
  description = "Community Prometheus Helm Addon Config"
  type        = any
  default     = {}
}

#-----------METRIC SERVER-------------
variable "metrics_server_enable" {
  type        = bool
  default     = false
  description = "Enabling metrics server on eks cluster"
}

variable "metrics_server_helm_chart" {
  type        = any
  default     = {}
  description = "Metrics Server Helm Addon Config"
}

#-----------TRAEFIK-------------
variable "traefik_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling Traefik Ingress Controller on eks cluster"
}

variable "traefik_helm_chart" {
  type        = any
  default     = {}
  description = "Traefik Helm Addon Config"
}

#-----------AGONES-------------
variable "agones_enable" {
  type        = bool
  default     = false
  description = "Enabling Agones Gaming Helm Chart"
}

variable "agones_helm_chart" {
  type        = any
  default     = {}
  description = "Agones GameServer Helm chart config"
}

#-----------AWS LB Ingress Controller-------------
variable "aws_lb_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "enabling LB Ingress Controller on eks cluster"
}

variable "aws_lb_ingress_controller_helm_app" {
  type        = any
  description = "Helm chart definition for aws_lb_ingress_controller"
  default     = {}
}

#-----------NGINX-------------
variable "ingress_nginx_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling NGINX Ingress Controller on EKS Cluster"
}

variable "nginx_helm_chart" {
  description = "NGINX Ingress Controller Helm Chart Configuration"
  type        = any
  default     = {}
}

#-----------SPARK K8S OPERATOR-------------
variable "spark_on_k8s_operator_enable" {
  type        = bool
  default     = false
  description = "Enabling Spark on K8s Operator on EKS Cluster"
}

variable "spark_on_k8s_operator_helm_chart" {
  description = "Spark on K8s Operator Helm Chart Configuration"
  type        = any
  default     = {}
}

#-----------AWS FOR FLUENT BIT-------------
variable "aws_for_fluentbit_enable" {
  type        = bool
  default     = false
  description = "Enabling FluentBit Addon on EKS Worker Nodes"
}

variable "aws_for_fluentbit_helm_chart" {
  type        = any
  description = "Helm chart definition for aws_for_fluent_bit"
  default     = {}
}

#-----------FARGATE FLUENT BIT-------------
variable "fargate_fluentbit_enable" {
  type        = bool
  default     = false
  description = "Enabling fargate_fluent_bit module on eks cluster"
}

variable "fargate_fluentbit_config" {
  type        = any
  description = "Fargate fluentbit configuration "
  default     = {}
}

#-----------CERT MANAGER-------------
variable "cert_manager_enable" {
  type        = bool
  default     = false
  description = "Enabling Cert Manager Helm Chart installation."
}

variable "cert_manager_helm_chart" {
  type        = any
  description = "Cert Manager Helm chart configuration"
  default     = {}
}
#-----------AWS OPEN TELEMETRY ADDON-------------
variable "aws_open_telemetry_enable" {
  type        = bool
  default     = false
  description = "Enable AWS Open Telemetry Distro Addon "
}

variable "aws_open_telemetry_addon" {
  type        = any
  default     = {}
  description = "AWS Open Telemetry Distro Addon Configuration"
}

#-----------ARGOCD ADDON-------------
variable "argocd_enable" {
  type        = bool
  default     = false
  description = "Enable ARGO CD Kubernetes Addon"
}

variable "argocd_helm_chart" {
  type        = any
  default     = {}
  description = "ARGO CD Kubernetes Addon Configuration"
}

variable "argocd_applications" {
  type        = any
  default     = {}
  description = "ARGO CD Applications config to bootstrap the cluster"
}

variable "argocd_manage_add_ons" {
  type        = bool
  default     = false
  description = "Enables managing add-on configuration via ArgoCD"
}

#-----------AWS NODE TERMINATION HANDLER-------------
variable "aws_node_termination_handler_enable" {
  type        = bool
  default     = false
  description = "Enabling AWS Node Termination Handler"
}

variable "aws_node_termination_handler_helm_chart" {
  type        = any
  description = "Helm chart definition for aws_node_termination_handler"
  default     = {}
}

#-----------KEDA ADDON-------------
variable "keda_enable" {
  type        = bool
  default     = false
  description = "Enable KEDA Event-based autoscaler for workloads on Kubernetes"
}

variable "keda_helm_chart" {
  type        = any
  default     = {}
  description = "KEDA Event-based autoscaler Kubernetes Addon Configuration"
}

variable "keda_create_irsa" {
  type        = bool
  description = "Indicates if the add-on should create a IAM role + service account"
  default     = true
}

variable "keda_irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies for a IAM role for service accounts"
  default     = []
}

#-----------TEAMS-------------
variable "application_teams" {
  description = "Map of maps of Application Teams to create"
  type        = any
  default     = {}
}

variable "platform_teams" {
  description = "Map of maps of platform teams to create"
  type        = any
  default     = {}
}

#-----------Vertical Pod Autoscaler(VPA) ADDON-------------
variable "vpa_enable" {
  type        = bool
  default     = false
  description = "Enable Kubernetes Vertical Pod Autoscaler"
}

variable "vpa_helm_chart" {
  type        = any
  default     = {}
  description = "Kubernetes Vertical Pod Autoscaler Helm chart config"
}

#-----------Apache YuniKorn ADDON-------------
variable "yunikorn_enable" {
  type        = bool
  default     = false
  description = "Enable Apache YuniKorn K8s scheduler"
}

variable "yunikorn_helm_chart" {
  type        = any
  default     = {}
  description = "YuniKorn K8s scheduler Helm chart config"
}
