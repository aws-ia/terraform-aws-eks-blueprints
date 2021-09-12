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

variable "terraform_version" {
  type        = string
  default     = "Terraform"
  description = "Terraform Version"
}
variable "org" {
  type        = string
  description = "tenant, which could be your organization name, e.g. aws'"
  default     = "aws"
}
variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = ""
}
variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}
variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = ""
}
variable "attributes" {
  type        = string
  default     = ""
  description = "Additional attributes (e.g. `1`)"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}
#----------------------------------------------------------
// VPC
#----------------------------------------------------------
variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = false
}
variable "enable_public_subnets" {
  description = "Enable public subnets for EKS Cluster"
  type        = bool
  default     = false
}
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for public subnets"
  type        = bool
  default     = false
}
variable "single_nat_gateway" {
  description = "Create single NAT gateway for all private subnets"
  type        = bool
  default     = true
}
variable "create_igw" {
  description = "Create internet gateway in public subnets"
  type        = bool
  default     = false
}
variable "enable_private_subnets" {
  description = "Enable private subnets for EKS Cluster"
  type        = bool
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
  default     = ""
}

variable "private_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  default     = []
}
variable "public_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  default     = []
}
variable "vpc_cidr_block" {
  type        = string
  default     = ""
  description = "VPC CIDR"
}
variable "public_subnets_cidr" {
  description = "list of Public subnets for the Worker nodes"
  default     = []
}
variable "private_subnets_cidr" {
  description = "list of Private subnets for the Worker nodes"
  default     = []
}

variable "create_vpc_endpoints" {
  type        = bool
  default     = false
  description = "Create VPC endpoints for Private subnets"
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false"
}
variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}
variable "enable_irsa" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}
#----------------------------------------------------------
// EKS CONTROL PLANE
#----------------------------------------------------------
variable "create_eks" {
  type    = bool
  default = false

}
variable "kubernetes_version" {
  type        = string
  default     = "1.20"
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
}
variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
}
variable "cluster_log_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
}

variable "vpc_cni_addon_version" {
  type        = string
  default     = "v1.8.0-eksbuild.1"
  description = "VPC CNI Addon verison"
}
variable "coredns_addon_version" {
  type        = string
  default     = "v1.8.3-eksbuild.1"
  description = "CoreDNS Addon verison"
}
variable "kube_proxy_addon_version" {
  type        = string
  default     = "v1.20.4-eksbuild.2"
  description = "KubeProxy Addon verison"
}
variable "enable_vpc_cni_addon" {
  type    = bool
  default = false
}
variable "enable_coredns_addon" {
  type    = bool
  default = false
}
variable "enable_kube_proxy_addon" {
  type    = bool
  default = false
}

#----------------------------------------------------------
// EKS WORKER NODES
#----------------------------------------------------------
variable "enable_managed_nodegroups" {
  description = "Enable self-managed worker groups"
  type        = bool
  default     = false
}

variable "managed_node_groups" {
  type    = any
  default = {}
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
  default = false
}
variable "fargate_profiles" {
  type    = any
  default = {}
}

variable "enable_windows_support" {
  type    = string
  default = false
}

#----------------------------------------------------------
# CONFIG MAP AWS-AUTH
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

variable "manage_aws_auth" {
  description = "Whether to apply the aws-auth configmap file."
  default     = true
}
variable "aws_auth_additional_labels" {
  description = "Additional kubernetes labels applied on aws-auth ConfigMap"
  default     = {}
  type        = map(string)
}

#----------------------------------------------------------
# HELM CHART VARIABLES
#----------------------------------------------------------
variable "public_docker_repo" {
  type        = bool
  default     = true
  description = "public docker repo access"
}

variable "metrics_server_enable" {
  type        = bool
  default     = false
  description = "Enabling metrics server on eks cluster"
}
variable "cluster_autoscaler_enable" {
  type        = bool
  default     = false
  description = "Enabling Cluster autoscaler on eks cluster"
}
variable "traefik_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling Traefik Ingress Controller on eks cluster"
}

variable "lb_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "enabling LB Ingress Controller on eks cluster"
}

variable "nginx_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "enabling Nginx Ingress Controller on eks cluster"
}

variable "aws_for_fluent_bit_enable" {
  type        = bool
  default     = false
  description = "Enabling aws_fluent_bit module on eks cluster"
}

variable "fargate_fluent_bit_enable" {
  type        = bool
  default     = false
  description = "Enabling fargate_fluent_bit module on eks cluster"
}

variable "ekslog_retention_in_days" {
  default     = 90
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
}

variable "agones_enable" {
  type        = bool
  default     = false
  description = "Enabling Agones Gaming Helm Chart"
}
variable "expose_udp" {
  type        = bool
  default     = false
  description = "Enabling Agones Gaming Helm Chart"
}

variable "aws_lb_image_tag" {
  default = "v2.2.1"
}

variable "aws_lb_helm_chart_version" {
  default = "1.2.3"
}

variable "metric_server_image_tag" {
  default = "v0.4.2"
}

variable "metric_server_helm_chart_version" {
  default = "2.12.1"
}

variable "cluster_autoscaler_image_tag" {
  default = "v1.20.0"
}

variable "cluster_autoscaler_helm_version" {
  default = "9.9.2"
}

variable "prometheus_helm_chart_version" {
  default = "14.4.0"
}

variable "prometheus_image_tag" {
  default = "v2.26.0"
}

variable "alert_manager_image_tag" {
  default = "v0.21.0"
}

variable "configmap_reload_image_tag" {
  default = "v0.5.0"
}

variable "node_exporter_image_tag" {
  default = "v1.1.2"
}

variable "pushgateway_image_tag" {
  default = "v1.3.1"
}

variable "prometheus_enable" {
  default = false
}

variable "aws_managed_prometheus_enable" {
  default = false
}

variable "traefik_helm_chart_version" {
  default = "10.0.0"
}

variable "traefik_image_tag" {
  default = "v2.4.9"
}

variable "nginx_helm_chart_version" {
  default = "3.33.0"
}

variable "nginx_image_tag" {
  default = "v0.47.0"
}

variable "aws_for_fluent_bit_image_tag" {
  default     = "2.13.0"
  description = "Docker image tag for aws_for_fluent_bit"
}

variable "aws_for_fluent_bit_helm_chart_version" {
  default     = "0.1.11"
  description = "Helm chart version for aws_for_fluent_bit"
}


