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

locals {
  image_url = var.public_docker_repo ? var.opentelemetry_image : "${var.private_container_repo_url}${var.opentelemetry_image}"
}

resource "kubernetes_namespace" "opentelemetry_system" {
  metadata {
    name = "opentelemetry-system"
  }
}

resource "helm_release" "opentelemetry-collector" {
  name       = "opentelemetry-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = var.opentelemetry_helm_chart
  version    = var.opentelemetry_helm_chart_version
  namespace  = kubernetes_namespace.opentelemetry_system.id
  timeout    = "1200"
  values = [templatefile("${path.module}/templates/open-telemetry-values.yaml", {
    image = local.image_url

    tag                                     = var.opentelemetry_image_tag
    command_name                            = var.opentelemetry_command_name
    enable_agent_collector                  = var.opentelemetry_enable_agent_collector
    enable_container_logs                   = var.opentelemetry_enable_container_logs
    enable_standalone_collector             = var.opentelemetry_enable_standalone_collector
    enable_autoscaling_standalone_collector = var.opentelemetry_enable_autoscaling_standalone_collector
    min_standalone_collectors               = var.opentelemetry_min_standalone_collectors
    max_standalone_collectors               = var.opentelemetry_max_standalone_collectors
  })]
}

