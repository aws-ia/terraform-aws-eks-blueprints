/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#  CLUSTER LABELS
variable "org" {
  type        = string
  description = "tenant, which could be your organization name, e.g. aws'"
  default     = ""
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "aws"
}

variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "terraform_version" {
  type        = string
  default     = "Terraform"
  description = "Terraform version"
}

# VPC Config for EKS Cluster
variable "vpc_id" {
  type        = string
  description = "VPC Id"
}

variable "private_subnet_ids" {
  description = "List of private subnets Ids for the worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnets Ids for the worker nodes"
  type        = list(string)
  default     = []
}

# EKS CONTROL PLANE
variable "create_eks" {
  type        = bool
  default     = false
  description = "Create EKS cluster"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.21"
  description = "Desired kubernetes version. If you do not specify a value, the latest available version is used"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the EKS private API server endpoint is enabled. Default to EKS resource and it is false"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the EKS public API server endpoint is enabled. Default to EKS resource and it is true"
}

variable "enable_irsa" {
  type        = bool
  default     = true
  description = "Enable IAM Roles for Service Accounts"
}

variable "cluster_enabled_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable"
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain cluster logs"
}

# EKS MANAGED ADDONS
variable "eks_addon_vpc_cni_config" {
  description = "ConfigMap for EKS VPC CNI Add-on"
  type        = any
  default     = {}
}

variable "eks_addon_coredns_config" {
  description = "ConfigMap for CoreDNS EKS Add-on"
  type        = any
  default     = {}
}

variable "eks_addon_kube_proxy_config" {
  description = "ConfigMap for EKS kube-proxy Add-on"
  type        = any
  default     = {}
}

variable "eks_addon_aws_ebs_csi_driver_config" {
  description = "ConfigMap for AWS EBS CSI driver Add-on"
  type        = any
  default     = {}
}

variable "enable_eks_addon_vpc_cni" {
  type        = bool
  default     = false
  description = "Enable Amazon VPC CNI Addon"
}

variable "enable_eks_addon_coredns" {
  type        = bool
  default     = false
  description = "Enable CoreDNS Addon"
}

variable "enable_eks_addon_kube_proxy" {
  type        = bool
  default     = false
  description = "Enable kube-proxy Addon"
}

variable "enable_eks_addon_aws_ebs_csi_driver" {
  type        = bool
  default     = false
  description = "Enable EKS Managed EBS CSI Driver Addon"
}

# EKS WORKER NODES
variable "managed_node_groups" {
  description = "Managed node groups configuration"
  type        = any
  default     = {}
}

variable "self_managed_node_groups" {
  description = "Self-managed node groups configuration"
  type        = any
  default     = {}
}

variable "fargate_profiles" {
  description = "Fargate profile configuration"
  type        = any
  default     = {}
}

# EKS WINDOWS SUPPORT
variable "enable_windows_support" {
  description = "Enable Windows support"
  type        = bool
  default     = false
}

# CONFIGMAP AWS-AUTH
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_additional_labels" {
  description = "Additional kubernetes labels applied on aws-auth ConfigMap"
  default     = {}
  type        = map(string)
}

# KUBERNETES ADDONS VARIABLES

#-----------EMR on EKS-------------------
variable "enable_emr_on_eks" {
  type        = bool
  default     = false
  description = "Enable EMR on EKS"
}

variable "emr_on_eks_teams" {
  description = "EMR on EKS Teams config"
  type        = any
  default     = {}
}

#-----------CLUSTER AUTOSCALER-------------
variable "enable_cluster_autoscaler" {
  type        = bool
  default     = false
  description = "Enable Cluster Autoscaler addon"
}

variable "cluster_autoscaler_helm_config" {
  type        = any
  default     = {}
  description = "Cluster Autoscaler Helm Chart config"
}

#-----------PROMETHEUS-------------
variable "enable_aws_managed_prometheus" {
  type        = bool
  default     = false
  description = "Enable AWS Managed Prometheus addon"
}

variable "aws_managed_prometheus_workspace_name" {
  type        = string
  default     = "aws-managed-prometheus-workspace"
  description = "AWS Managed Prometheus WorkSpace Name"
}

variable "enable_prometheus" {
  description = "Enable community Prometheus addon"
  type        = bool
  default     = false
}

variable "prometheus_helm_config" {
  description = "Community Prometheus Helm Chart config"
  type        = any
  default     = {}
}

#-----------METRIC SERVER-------------
variable "enable_metrics_server" {
  type        = bool
  default     = false
  description = "Enable metrics server addon"
}

variable "metrics_server_helm_config" {
  type        = any
  default     = {}
  description = "Metrics Server Helm Chart config"
}

#-----------TRAEFIK-------------
variable "enable_traefik" {
  type        = bool
  default     = false
  description = "Enable Traefik addon"
}

variable "traefik_helm_config" {
  type        = any
  default     = {}
  description = "Traefik Helm Chart config"
}

#-----------AGONES-------------
variable "enable_agones" {
  type        = bool
  default     = false
  description = "Enable Agones GameServer addon"
}

variable "agones_helm_config" {
  type        = any
  default     = {}
  description = "Agones GameServer Helm Chart config"
}

#-----------AWS LB Controller-------------
variable "enable_aws_load_balancer_controller" {
  type        = bool
  default     = false
  description = "Enable AWS Load Balancer Controller addon"
}

variable "aws_load_balancer_controller_helm_config" {
  type        = any
  description = "AWS Load Balancer Controller Helm Chart config"
  default     = {}
}

#-----------NGINX-------------
variable "enable_ingress_nginx" {
  type        = bool
  default     = false
  description = "Enable Ingress Nginx addon"
}

variable "ingress_nginx_helm_config" {
  description = "Ingress Nginx Helm Chart config"
  type        = any
  default     = {}
}

#-----------SPARK ON K8S OPERATOR-------------
variable "enable_spark_on_k8s_operator" {
  type        = bool
  default     = false
  description = "Enable Spark on K8s Operator"
}

variable "spark_on_k8s_operator_helm_config" {
  description = "Spark on K8s Operator Helm Chart config"
  type        = any
  default     = {}
}

#-----------AWS FOR FLUENT BIT-------------
variable "enable_aws_for_fluentbit" {
  type        = bool
  default     = false
  description = "Enable AWS for FluentBit addon"
}

variable "aws_for_fluentbit_helm_config" {
  type        = any
  description = "AWS for FluentBit Helm Chart config"
  default     = {}
}

#-----------FARGATE FLUENT BIT-------------
variable "enable_fargate_fluentbit" {
  type        = bool
  default     = false
  description = "Enable FluentBit for EKS on Fargate"
}

variable "fargate_fluentbit_config" {
  type        = any
  description = "EKS on Fargate fluentbit config"
  default     = {}
}

#-----------CERT MANAGER-------------
variable "enable_cert_manager" {
  type        = bool
  default     = false
  description = "Enable Cert Manager addon"
}

variable "cert_manager_helm_config" {
  type        = any
  description = "Cert Manager Helm chart config"
  default     = {}
}
#-----------AWS OPEN TELEMETRY-------------
variable "enable_aws_open_telemetry" {
  type        = bool
  default     = false
  description = "Enable AWS Open Telemetry addon"
}

variable "aws_open_telemetry_addon_config" {
  type        = any
  default     = {}
  description = "AWS Open Telemetry Distro cddon configuration"
}

#-----------ARGOCD-------------
variable "enable_argocd" {
  type        = bool
  default     = false
  description = "Enable Argo CD Kubernetes addon"
}

variable "argocd_helm_config" {
  type        = any
  default     = {}
  description = "Argo CD Helm Chart config"
}

variable "argocd_applications" {
  type        = any
  default     = {}
  description = "Argo CD applications config to bootstrap the cluster"
}

variable "argocd_manage_add_ons" {
  type        = bool
  default     = false
  description = "Enables managing add-on configuration via ArgoCD"
}

#-----------AWS NODE TERMINATION HANDLER-------------
variable "enable_aws_node_termination_handler" {
  type        = bool
  default     = false
  description = "Enable AWS Node Termination Handler addon (only applicable for self-managed workers)"
}

variable "aws_node_termination_handler_helm_config" {
  type        = any
  description = "AWS Node Termination Handler Helm Chart config"
  default     = {}
}

#-----------KEDA-------------
variable "enable_keda" {
  type        = bool
  default     = false
  description = "Enable KEDA Event-based autoscaler for workloads on Kubernetes"
}

variable "keda_helm_config" {
  type        = any
  default     = {}
  description = "KEDA Helm Chart config"
}

variable "keda_create_irsa" {
  type        = bool
  description = "Indicates if the add-on should create a IAM role for service account"
  default     = true
}

variable "keda_irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies for a IAM role for service accounts"
  default     = []
}

#-----------Vertical Pod Autoscaler(VPA) ADDON-------------
variable "enable_vpa" {
  type        = bool
  default     = false
  description = "Enable Kubernetes Vertical Pod Autoscaler (VPA)"
}

variable "vpa_helm_config" {
  type        = any
  default     = {}
  description = "Kubernetes Vertical Pod Autoscaler Helm Chart config"
}

#-----------Apache YuniKorn ADDON-------------
variable "enable_yunikorn" {
  type        = bool
  default     = false
  description = "Enable Apache YuniKorn K8s scheduler"
}

variable "yunikorn_helm_config" {
  type        = any
  default     = {}
  description = "YuniKorn K8s scheduler Helm Chart config"
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
