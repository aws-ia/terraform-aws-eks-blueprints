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

variable "prometheus_helm_chart_url" {
  type    = string
  default = "https://prometheus-community.github.io/helm-charts"
}

variable "prometheus_helm_chart_name" {
  type    = string
  default = "prometheus"
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

variable "private_container_repo_url" {
  type = string
}

variable "service_account_amp_ingest_name" {
  type = string
}
variable "prometheus_enable" {
  type        = bool
  default     = false
  description = "Enabling prometheus on eks cluster"
}

variable "prometheus_helm_chart_version" {
  type    = string
  default = "14.4.0"
}
variable "prometheus_repo" {
  type    = string
  default = "quay.io/prometheus/prometheus"
}

variable "prometheus_image_tag" {
  type    = string
  default = "v2.26.0"
}

variable "alert_manager_repo" {
  type    = string
  default = "quay.io/prometheus/alertmanager"
}

variable "alert_manager_image_tag" {
  type    = string
  default = "v0.21.0"
}

variable "configmap_reload_repo" {
  type    = string
  default = "jimmidyson/configmap-reload"
}

variable "configmap_reload_image_tag" {
  type    = string
  default = "v0.5.0"
}

variable "node_exporter_repo" {
  type    = string
  default = "quay.io/prometheus/node-exporter"
}

variable "node_exporter_image_tag" {
  type    = string
  default = "v1.1.2"
}

variable "pushgateway_repo" {
  type    = string
  default = "prom/pushgateway"
}

variable "pushgateway_image_tag" {
  type    = string
  default = "v1.3.1"
}

variable "public_docker_repo" {
  type = bool
}
