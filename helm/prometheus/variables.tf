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


variable "amp_workspace_id" {}
variable "region" {}
variable "amp_ingest_role_arn" {}

variable "private_container_repo_url" {}

variable "service_account_amp_ingest_name" {
}
variable "prometheus_enable" {
  type        = bool
  default     = false
  description = "Enabling prometheus on eks cluster"
}

variable "prometheus_helm_chart_version" {
  default = "14.4.0"
}
variable "prometheus_repo" {
  default = "quay.io/prometheus/prometheus"
}

variable "prometheus_image_tag" {
  default = "v2.26.0"
}

variable "alert_manager_repo" {
  default = "quay.io/prometheus/alertmanager"
}

variable "alert_manager_image_tag" {
  default = "v0.21.0"
}

variable "configmap_reload_repo" {
  default = "jimmidyson/configmap-reload"
}

variable "configmap_reload_image_tag" {
  default = "v0.5.0"
}

variable "node_exporter_repo" {
  default = "quay.io/prometheus/node-exporter"
}

variable "node_exporter_image_tag" {
  default = "v1.1.2"
}

variable "pushgateway_repo" {
  default = "prom/pushgateway"
}

variable "pushgateway_image_tag" {
  default = "v1.3.1"
}

variable "public_docker_repo" {}
