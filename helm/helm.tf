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

module "metrics_server" {
  count                            = var.metrics_server_enable == true ? 1 : 0
  source                           = "./metrics_server"
  private_container_repo_url       = var.private_container_repo_url
  public_docker_repo               = var.public_docker_repo
  metric_server_helm_chart_version = var.metric_server_helm_chart_version
  metric_server_image_tag          = var.metric_server_image_tag
}

module "cluster_autoscaler" {
  count                           = var.cluster_autoscaler_enable == true ? 1 : 0
  source                          = "./cluster_autoscaler"
  private_container_repo_url      = var.private_container_repo_url
  eks_cluster_id                  = var.eks_cluster_id
  public_docker_repo              = var.public_docker_repo
  cluster_autoscaler_image_tag    = var.cluster_autoscaler_image_tag
  cluster_autoscaler_helm_version = var.cluster_autoscaler_helm_version
}

module "lb_ingress_controller" {
  count                      = var.lb_ingress_controller_enable == true ? 1 : 0
  source                     = "./lb_ingress_controller"
  private_container_repo_url = var.private_container_repo_url
  clusterName                = var.eks_cluster_id
  eks_oidc_issuer_url        = var.eks_oidc_issuer_url
  eks_oidc_provider_arn      = var.eks_oidc_provider_arn
  public_docker_repo         = var.public_docker_repo
  aws_lb_image_tag           = var.aws_lb_image_tag
  aws_lb_helm_chart_version  = var.aws_lb_helm_chart_version
}

module "traefik_ingress" {
  count                      = var.traefik_ingress_controller_enable == true ? 1 : 0
  source                     = "./traefik_ingress"
  private_container_repo_url = var.private_container_repo_url
  account_id                 = data.aws_caller_identity.current.account_id
  s3_nlb_logs                = var.s3_nlb_logs
  public_docker_repo         = var.public_docker_repo
  traefik_helm_chart_version = var.traefik_helm_chart_version
  traefik_image_tag          = var.traefik_image_tag
  //  tls_cert_arn = ""
}

module "nginx_ingress" {
  count                      = var.nginx_ingress_controller_enable == true ? 1 : 0
  source                     = "./nginx_ingress"
  private_container_repo_url = var.private_container_repo_url
  account_id                 = data.aws_caller_identity.current.account_id
  public_docker_repo         = var.public_docker_repo
  nginx_helm_chart_version   = var.nginx_helm_chart_version
  nginx_image_tag            = var.nginx_image_tag
}

module "aws-for-fluent-bit" {
  count                                 = var.aws_for_fluent_bit_enable == true ? 1 : 0
  source                                = "./aws-for-fluent-bit"
  private_container_repo_url            = var.private_container_repo_url
  cluster_id                            = var.eks_cluster_id
  ekslog_retention_in_days              = var.ekslog_retention_in_days
  public_docker_repo                    = var.public_docker_repo
  aws_for_fluent_bit_image_tag          = var.aws_for_fluent_bit_image_tag
  aws_for_fluent_bit_helm_chart_version = var.aws_for_fluent_bit_helm_chart_version
}

module "fargate_fluentbit" {
  count            = var.fargate_fluent_bit_enable == true ? 1 : 0
  source           = "./fargate_fluentbit"
  eks_cluster_id   = var.eks_cluster_id
  fargate_iam_role = var.fargate_iam_role
}

module "agones" {
  count                      = var.agones_enable == true ? 1 : 0
  source                     = "./agones"
  public_docker_repo         = var.public_docker_repo
  private_container_repo_url = var.private_container_repo_url
  cluster_id                 = var.eks_cluster_id
  s3_nlb_logs                = var.s3_nlb_logs
  expose_udp                 = var.expose_udp
  eks_sg_id                  = var.eks_security_group_id
}

module "prometheus" {
  count                           = var.prometheus_enable == true ? 1 : 0
  source                          = "./prometheus"
  private_container_repo_url      = var.private_container_repo_url
  public_docker_repo              = var.public_docker_repo
  pushgateway_image_tag           = var.pushgateway_image_tag
  node_exporter_image_tag         = var.node_exporter_image_tag
  configmap_reload_image_tag      = var.configmap_reload_image_tag
  alert_manager_image_tag         = var.alert_manager_image_tag
  prometheus_image_tag            = var.prometheus_image_tag
  prometheus_helm_chart_version   = var.prometheus_helm_chart_version
  service_account_amp_ingest_name = var.service_account_amp_ingest_name
  amp_ingest_role_arn             = var.amp_ingest_role_arn
  amp_workspace_id                = var.amp_workspace_id
  region                          = var.region
}

module "opentelemetry_collector" {
  count                                                 = var.opentelemetry_enable == true ? 1 : 0
  source                                                = "./opentelemetry_collector"
  private_container_repo_url                            = var.private_container_repo_url
  public_docker_repo                                    = var.public_docker_repo
  opentelemetry_command_name                            = var.opentelemetry_command_name
  opentelemetry_helm_chart                              = var.opentelemetry_helm_chart
  opentelemetry_image                                   = var.opentelemetry_image
  opentelemetry_image_tag                               = var.opentelemetry_image_tag
  opentelemetry_helm_chart_version                      = var.opentelemetry_helm_chart_version
  opentelemetry_enable_agent_collector                  = var.opentelemetry_enable_agent_collector
  opentelemetry_enable_standalone_collector             = var.opentelemetry_enable_standalone_collector
  opentelemetry_enable_autoscaling_standalone_collector = var.opentelemetry_enable_autoscaling_standalone_collector
  opentelemetry_enable_container_logs                   = var.opentelemetry_enable_container_logs
  opentelemetry_min_standalone_collectors               = var.opentelemetry_min_standalone_collectors
  opentelemetry_max_standalone_collectors               = var.opentelemetry_max_standalone_collectors
}
