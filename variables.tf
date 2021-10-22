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
#----------------------------------------------------------
#  CLUSTER LABELS
#----------------------------------------------------------
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
  description = "Terraform Version"
}
#----------------------------------------------------------
# VPC Config for EKS Cluster
#----------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC id"
}
variable "private_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  type        = list(string)
}
variable "public_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  type        = list(string)
  default     = []
}
#----------------------------------------------------------
# EKS CONTROL PLANE
#----------------------------------------------------------
variable "create_eks" {
  type    = bool
  default = false
}
variable "kubernetes_version" {
  type        = string
  default     = "1.21"
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
}
variable "cluster_endpoint_private_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false"
}
variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}
variable "enable_irsa" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}
variable "cluster_enabled_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
}
variable "cluster_log_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
}
#----------------------------------------------------------
# EKS MANAGED ADDONS
#----------------------------------------------------------
variable "enable_vpc_cni_addon" {
  type        = bool
  default     = false
  description = "Enable VPC CNI Addon"
}
variable "enable_coredns_addon" {
  type        = bool
  default     = false
  description = "Enable CoreDNS Addon"
}
variable "enable_kube_proxy_addon" {
  type        = bool
  default     = false
  description = "Enable Kube Proxy Addon"
}
variable "vpc_cni_addon_version" {
  type        = string
  default     = "v1.8.0-eksbuild.1"
  description = "VPC CNI Addon version"
}
variable "coredns_addon_version" {
  type        = string
  default     = "v1.8.3-eksbuild.1"
  description = "CoreDNS Addon version"
}
variable "kube_proxy_addon_version" {
  type        = string
  default     = "v1.20.4-eksbuild.2"
  description = "KubeProxy Addon version"
}
#----------------------------------------------------------
# EKS WORKER NODES
#----------------------------------------------------------
variable "enable_managed_nodegroups" {
  description = "Enable self-managed worker groups"
  type        = bool
  default     = false
}
variable "managed_node_groups" {
  description = "Managed Node groups configuration"
  type        = any
  default     = {}
}
variable "enable_self_managed_nodegroups" {
  description = "Enable self-managed worker groups"
  type        = bool
  default     = false
}
variable "self_managed_node_groups" {
  type    = any
  default = {}
}
variable "enable_fargate" {
  description = "Enable Fargate profiles"
  type        = bool
  default     = false
}
variable "fargate_profiles" {
  description = "Fargate Profile configuration"
  type        = any
  default     = {}
}
#----------------------------------------------------------
# EKS WINDOWS SUPPORT
#----------------------------------------------------------
variable "enable_windows_support" {
  description = "Enable Windows support"
  type        = bool
  default     = false
}
#----------------------------------------------------------
# CONFIGMAP AWS-AUTH
#----------------------------------------------------------
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. "
  type        = list(string)
  default     = []
}
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. "
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
#----------------------------------------------------------
# KUBERNETES ADDONS VARIABLES
#----------------------------------------------------------
variable "enable_emr_on_eks" {
  type        = bool
  default     = false
  description = "Enabling EMR on EKS Config"
}
variable "emr_on_eks_username" {
  type        = string
  default     = "emr-containers"
  description = "EMR on EKS username"
}
variable "emr_on_eks_namespace" {
  type        = string
  default     = "spark"
  description = "EMR on EKS NameSpace"
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
variable "aws_managed_prometheus_workspace_name" {
  type        = string
  default     = "aws-managed-prometheus-workspace"
  description = "AWS Managed Prometheus WorkSpace Name"
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
variable "private_container_repo_url" {
  type        = string
  default     = ""
  description = "Private container image repo url (e.g, artifactory url or ECR url)"
}
variable "public_docker_repo" {
  type        = bool
  default     = true
  description = "public docker repo access"
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
variable "aws_lb_image_repo_name" {
  type    = string
  default = "amazon/aws-load-balancer-controller"
}
variable "aws_lb_helm_repo_url" {
  type    = string
  default = "https://aws.github.io/eks-charts"
}
variable "aws_lb_helm_helm_chart_name" {
  type    = string
  default = "aws-load-balancer-controller"
}
variable "aws_lb_image_tag" {
  type    = string
  default = "v2.2.4"
}
variable "aws_lb_helm_chart_version" {
  type    = string
  default = "1.2.7"
}
#-----------NGINX-------------
variable "nginx_ingress_controller_enable" {
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
  description = "Enabling Cert Manager Helm Chart installation. It is automatically enabled if Windows support is enabled."
}
variable "cert_manager_helm_chart" {
  type        = any
  description = "Cert Manager Helm chart configuration"
  default     = {}
}
#------WINDOWS VPC CONTROLLERS-------------
variable "windows_vpc_controllers_helm_chart" {
  type        = any
  description = "Windows VPC Controllers Helm chart configuration"
  default     = {}
}
#-----------AWS OPEN TELEMETRY ADDON-------------
variable "aws_open_telemetry_enable" {
  type    = bool
  default = false
}

variable "aws_open_telemetry_addon" {
  type        = any
  default     = {}
  description = "AWS Open Telemetry Distro Addon Configuration"
}
