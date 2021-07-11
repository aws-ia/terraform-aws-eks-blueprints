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

//helm install prometheus-for-amp prometheus-community/prometheus -n prometheus -f ./amp_ingest_override_values.yaml \
//--set serviceAccounts.server.annotations."eks\.amazonaws\.com/role-arn"="${IAM_PROXY_PROMETHEUS_ROLE_ARN}" \
//--set server.remoteWrite[0].url="https://aps-workspaces.${AWS_REGION}.amazonaws.com/workspaces/${WORKSPACE_ID}/api/v1/remote_write" \
//--set server.remoteWrite[0].sigv4.region=${AWS_REGION}


locals {
  prometheus_repo_url       = var.public_docker_repo ? var.prometheus_repo : "${var.private_container_repo_url}${var.prometheus_repo}"
  alert_manager_repo_url    = var.public_docker_repo ? var.alert_manager_repo : "${var.private_container_repo_url}${var.alert_manager_repo}"
  configmap_reload_repo_url = var.public_docker_repo ? var.configmap_reload_repo : "${var.private_container_repo_url}${var.configmap_reload_repo}"
  node_exporter_repo_url    = var.public_docker_repo ? var.node_exporter_repo : "${var.private_container_repo_url}${var.node_exporter_repo}"
  pushgateway_repo_url      = var.public_docker_repo ? var.pushgateway_repo : "${var.private_container_repo_url}${var.pushgateway_repo}"
}

resource "helm_release" "prometheus" {

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_helm_chart_version
  namespace  = "prometheus"
  timeout    = "1200"
  //  app_version = "2.26.0"

  values = [templatefile("${path.module}/templates/prometheus.yaml", {
    amp_workspace_url = "https://aps-workspaces.${var.region}.amazonaws.com/workspaces/${var.amp_workspace_id}/api/v1/remote_write"
    //    amp_workspace_url = "http://localhost:8005/workspaces/${var.amp_workspace_id}/api/v1/remote_write"
    region            = var.region
    server_annotation = var.amp_ingest_role_arn
    //    server_annotation = "arn:aws:iam::327949925549:role/amp-iamproxy-ingest-role"
    prometheus_repo_url  = local.prometheus_repo_url
    prometheus_image_tag = var.prometheus_image_tag

    alert_manager_repo_url  = local.alert_manager_repo_url
    alert_manager_image_tag = var.alert_manager_image_tag

    configmap_reload_repo_url  = local.configmap_reload_repo_url
    configmap_reload_image_tag = var.configmap_reload_image_tag

    node_exporter_repo_url  = local.node_exporter_repo_url
    node_exporter_image_tag = var.node_exporter_image_tag

    pushgateway_repo_url            = local.pushgateway_repo_url
    pushgateway_image_tag           = var.pushgateway_image_tag
    service_account_amp_ingest_name = var.service_account_amp_ingest_name

  })]

}
