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

variable "metrics_server_enable" {
  type        = bool
  default     = true
  description = "Enabling metrics server on eks cluster"
}
variable "cluster_autoscaler_enable" {
  type        = bool
  default     = true
  description = "Enabling cluster autoscaler server on eks cluster"
}
variable "traefik_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling Traefik Ingress on eks cluster"
}

variable "lb_ingress_controller_enable" {
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

variable "s3_nlb_logs" {
  description = "S3 bucket for NLB Logs"
}

variable "eks_cluster_id" {
  description = "EKS cluster Id"
}

variable "ekslog_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days."
}

variable "public_docker_repo" {}

variable "eks_oidc_issuer_url" {}

variable "eks_oidc_provider_arn" {}

variable "expose_udp" {}

variable "agones_enable" {
  type        = bool
  default     = false
  description = "Enabling agones on eks cluster"
}

variable "eks_security_group_id" {}

variable "aws_lb_image_tag" {}

variable "aws_lb_helm_chart_version" {}

variable "metric_server_image_tag" {}

variable "metric_server_helm_chart_version" {}

variable "cluster_autoscaler_image_tag" {}

variable "cluster_autoscaler_helm_version" {}


variable "prometheus_enable" {
  type        = bool
  default     = false
  description = "Enabling prometheus on eks cluster"
}

variable "private_container_repo_url" {}

variable "prometheus_helm_chart_version" {}

variable "prometheus_image_tag" {}

variable "alert_manager_image_tag" {}

variable "configmap_reload_image_tag" {}

variable "node_exporter_image_tag" {}

variable "pushgateway_image_tag" {}

variable "service_account_amp_ingest_name" {}

variable "amp_workspace_id" {}

variable "region" {}

variable "amp_ingest_role_arn" {}

variable "traefik_helm_chart_version" {}

variable "traefik_image_tag" {}

variable "nginx_helm_chart_version" {}

variable "nginx_image_tag" {}

variable "aws_for_fluent_bit_image_tag" {}

variable "aws_for_fluent_bit_helm_chart_version" {}

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
