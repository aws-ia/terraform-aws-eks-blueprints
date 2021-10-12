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

variable "traefik_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling Traefik Ingress on eks cluster"
}

variable "traefik_helm_chart" {
  type    = any
  default = {}
}

variable "metrics_server_enable" {
  type        = bool
  default     = true
  description = "Enabling metrics server on eks cluster"
}

variable "metrics_server_helm_chart" {
  type    = any
  default = {}
}

variable "cluster_autoscaler_enable" {
  type        = bool
  default     = true
  description = "Enabling cluster autoscaler server on eks cluster"
}

variable "cluster_autoscaler_helm_chart" {
  type    = any
  default = {}
}

variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster Id"
}

variable "aws_lb_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling LB Ingress controller on eks cluster"
}

variable "nginx_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling Nginx Ingress on eks cluster"
}

variable "aws_for_fluent_bit_enable" {
  type        = bool
  default     = false
  description = "Enabling aws_fluent_bit on eks cluster"
}

variable "fargate_fluent_bit_enable" {
  type        = bool
  default     = false
  description = "Enabling fargate_fluent_bit on eks cluster"
}

variable "ekslog_retention_in_days" {
  type        = number
  description = "Number of days to retain log events. Default retention - 90 days."
}

variable "public_docker_repo" {
  type = bool
}

variable "eks_oidc_issuer_url" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type = string
}

variable "agones_image_repo" {
  type    = string
  default = "gcr.io/agones-images"
}

variable "agones_image_tag" {
  type    = string
  default = "1.15.0"
}

variable "agones_helm_chart_name" {
  type    = string
  default = "agones"
}

variable "agones_helm_chart_url" {
  type    = string
  default = "https://agones.dev/chart/stable"
}

variable "agones_game_server_maxport" {
  type    = number
  default = 8000
}
variable "agones_game_server_minport" {
  type    = number
  default = 7000
}

variable "expose_udp" {
  type    = bool
  default = false
}

variable "agones_enable" {
  type        = bool
  default     = false
  description = "Enabling agones on eks cluster"
}

variable "eks_security_group_id" {
  type = string
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
  type = string
}

variable "aws_lb_helm_chart_version" {
  type = string
}

variable "prometheus_enable" {
  type        = bool
  default     = false
  description = "Enabling prometheus on eks cluster"
}

variable "private_container_repo_url" {
  type = string
}

variable "prometheus_helm_chart_url" {
  type    = string
  default = "https://prometheus-community.github.io/helm-charts"
}

variable "prometheus_helm_chart_name" {
  type    = string
  default = "prometheus"
}

variable "prometheus_helm_chart_version" {
  type = string
}

variable "prometheus_image_tag" {
  type = string
}

variable "alert_manager_image_tag" {
  type = string
}

variable "configmap_reload_image_tag" {
  type = string
}

variable "node_exporter_image_tag" {
  type = string
}

variable "pushgateway_image_tag" {
  type = string
}

variable "service_account_amp_ingest_name" {
  type = string
}

variable "amp_workspace_id" {
  type = string
}

variable "region" {
  type = string
}

variable "amp_ingest_role_arn" {
  type = string
}


variable "nginx_image_repo_name" {
  type    = string
  default = "ingress-nginx/controller"
}

variable "nginx_helm_chart_url" {
  type    = string
  default = "https://kubernetes.github.io/ingress-nginx"
}
variable "nginx_helm_chart_name" {
  type    = string
  default = "ingress-nginx"
}

variable "nginx_helm_chart_version" {
  type = string
}

variable "nginx_image_tag" {
  type = string
}

variable "aws_for_fluent_bit_image_repo_name" {
  type    = string
  default = "amazon/aws-for-fluent-bit"
}

variable "aws_for_fluent_bit_helm_chart_url" {
  type    = string
  default = "https://aws.github.io/eks-charts"
}
variable "aws_for_fluent_bit_helm_chart_name" {
  type    = string
  default = "aws-for-fluent-bit"
}

variable "aws_for_fluent_bit_image_tag" {
  type = string
}

variable "aws_for_fluent_bit_helm_chart_version" {
  type = string
}

variable "cert_manager_enable" {
  type        = bool
  default     = false
  description = "Enabling Cert Manager Helm Chart installation"
}
variable "cert_manager_image_tag" {
  type        = string
  default     = "v1.5.3"
  description = "Docker image tag for cert-manager controller"
}
variable "cert_manager_helm_chart_version" {
  type        = string
  default     = "v1.5.3"
  description = "Helm chart version for cert-manager"
}
variable "cert_manager_install_crds" {
  type        = bool
  description = "Whether Cert Manager CRDs should be installed as part of the cert-manager Helm chart installation"
  default     = true
}

variable "cert_manager_helm_chart_url" {
  type    = string
  default = "https://charts.jetstack.io"
}

variable "cert_manager_helm_chart_name" {
  type    = string
  default = "cert-manager"
}

variable "cert_manager_image_repo_name" {
  type    = string
  default = "quay.io/jetstack/cert-manager-controller"
}

variable "windows_vpc_controllers_enable" {
  type        = bool
  default     = false
  description = "Enabling Windows VPC Controllers Helm Chart installation"
}
variable "windows_vpc_resource_controller_image_tag" {
  type        = string
  default     = "v0.2.7"
  description = "Docker image tag for Windows VPC resource controller"
}
variable "windows_vpc_admission_webhook_image_tag" {
  type        = string
  default     = "v0.2.7"
  description = "Docker image tag for Windows VPC admission webhook controller"
}

variable "aws_open_telemetry_enable" {}

variable "aws_open_telemetry_namespace" {
  description = "WS Open telemetry namespace"
}

variable "aws_open_telemetry_emitter_otel_resource_attributes" {
  description = "AWS Open telemetry emitter otel resource attributes"
}

variable "aws_open_telemetry_emitter_name" {
  description = "AWS Open telemetry emitter image name"
}

variable "aws_open_telemetry_emitter_image" {
  description = "AWS Open telemetry emitter image id and tag"
}

variable "aws_open_telemetry_collector_image" {
  description = "AWS Open telemetry collector image id and tag"
}

variable "aws_open_telemetry_aws_region" {
  description = "AWS Open telemetry region"
}

variable "aws_open_telemetry_emitter_oltp_endpoint" {
  description = "AWS Open telemetry OLTP endpoint"
}

variable "aws_open_telemetry_mg_node_iam_role_arns" {
  type    = list(string)
  default = []
}

variable "aws_open_telemetry_self_mg_node_iam_role_arns" {
  type    = list(string)
  default = []
}

variable "opentelemetry_enable" {
}

variable "opentelemetry_helm_chart_url" {}

variable "opentelemetry_image_tag" {}

variable "opentelemetry_image" {}

variable "opentelemetry_helm_chart_version" {}

variable "opentelemetry_helm_chart" {}

variable "opentelemetry_command_name" {}

variable "opentelemetry_min_standalone_collectors" {}

variable "opentelemetry_max_standalone_collectors" {}

variable "opentelemetry_enable_standalone_collector" {}

variable "opentelemetry_enable_agent_collector" {}

variable "opentelemetry_enable_autoscaling_standalone_collector" {}

variable "opentelemetry_enable_container_logs" {}
