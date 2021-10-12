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
  count                     = var.metrics_server_enable == true ? 1 : 0
  source                    = "./metrics-server"
  metrics_server_helm_chart = var.metrics_server_helm_chart
}

module "cluster_autoscaler" {
  count                         = var.cluster_autoscaler_enable == true ? 1 : 0
  source                        = "./cluster-autoscaler"
  eks_cluster_id                = var.eks_cluster_id
  cluster_autoscaler_helm_chart = var.cluster_autoscaler_helm_chart
}

module "lb_ingress_controller" {
  count  = var.aws_lb_ingress_controller_enable == true ? 1 : 0
  source = "./lb-ingress-controller"

  private_container_repo_url  = var.private_container_repo_url
  clusterName                 = var.eks_cluster_id
  eks_oidc_issuer_url         = var.eks_oidc_issuer_url
  eks_oidc_provider_arn       = var.eks_oidc_provider_arn
  public_docker_repo          = var.public_docker_repo
  aws_lb_image_tag            = var.aws_lb_image_tag
  aws_lb_helm_chart_version   = var.aws_lb_helm_chart_version
  aws_lb_image_repo_name      = var.aws_lb_image_repo_name
  aws_lb_helm_repo_url        = var.aws_lb_helm_repo_url
  aws_lb_helm_helm_chart_name = var.aws_lb_helm_helm_chart_name
}

module "traefik_ingress" {
  count              = var.traefik_ingress_controller_enable == true ? 1 : 0
  source             = "./traefik-ingress"
  traefik_helm_chart = var.traefik_helm_chart
}

module "nginx_ingress" {
  count  = var.nginx_ingress_controller_enable == true ? 1 : 0
  source = "./nginx-ingress"

  private_container_repo_url = var.private_container_repo_url
  account_id                 = data.aws_caller_identity.current.account_id
  public_docker_repo         = var.public_docker_repo
  nginx_helm_chart_version   = var.nginx_helm_chart_version
  nginx_image_tag            = var.nginx_image_tag
  nginx_image_repo_name      = var.nginx_image_repo_name
}

module "aws-for-fluent-bit" {
  count  = var.aws_for_fluent_bit_enable == true ? 1 : 0
  source = "./aws-for-fluent-bit"

  private_container_repo_url            = var.private_container_repo_url
  cluster_id                            = var.eks_cluster_id
  ekslog_retention_in_days              = var.ekslog_retention_in_days
  public_docker_repo                    = var.public_docker_repo
  aws_for_fluent_bit_image_tag          = var.aws_for_fluent_bit_image_tag
  aws_for_fluent_bit_helm_chart_version = var.aws_for_fluent_bit_helm_chart_version
  aws_for_fluent_bit_image_repo_name    = var.aws_for_fluent_bit_image_repo_name

}

module "fargate_fluentbit" {
  count          = var.fargate_fluent_bit_enable == true ? 1 : 0
  source         = "./fargate-fluentbit"
  eks_cluster_id = var.eks_cluster_id
}

module "agones" {
  count  = var.agones_enable == true ? 1 : 0
  source = "./agones"

  public_docker_repo         = var.public_docker_repo
  private_container_repo_url = var.private_container_repo_url
  cluster_id                 = var.eks_cluster_id
  expose_udp                 = var.expose_udp
  eks_sg_id                  = var.eks_security_group_id
}

module "prometheus" {
  count  = var.prometheus_enable == true ? 1 : 0
  source = "./prometheus"

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

module "cert_manager" {
  count  = var.cert_manager_enable == true ? 1 : 0
  source = "./cert-manager"

  private_container_repo_url      = var.private_container_repo_url
  public_docker_repo              = var.public_docker_repo
  cert_manager_helm_chart_version = var.cert_manager_helm_chart_version
  cert_manager_image_tag          = var.cert_manager_image_tag
  cert_manager_install_crds       = var.cert_manager_install_crds
  cert_manager_helm_chart_name    = var.cert_manager_helm_chart_name
  cert_manager_helm_chart_url     = var.cert_manager_helm_chart_url
  cert_manager_image_repo_name    = var.cert_manager_image_repo_name

}

module "windows_vpc_controllers" {
  count  = var.windows_vpc_controllers_enable == true ? 1 : 0
  source = "./windows-vpc-controllers"

  private_container_repo_url    = var.private_container_repo_url
  public_docker_repo            = var.public_docker_repo
  resource_controller_image_tag = var.windows_vpc_resource_controller_image_tag
  admission_webhook_image_tag   = var.windows_vpc_admission_webhook_image_tag
  depends_on = [
    module.cert_manager
  ]
}

module "aws_opentelemetry_collector" {
  count  = var.aws_open_telemetry_enable == true ? 1 : 0
  source = "./aws-otel-eks"

  aws_open_telemetry_aws_region                       = var.aws_open_telemetry_aws_region == "" ? data.aws_region.current.id : var.aws_open_telemetry_aws_region
  aws_open_telemetry_emitter_image                    = var.aws_open_telemetry_emitter_image
  aws_open_telemetry_collector_image                  = var.aws_open_telemetry_collector_image
  aws_open_telemetry_emitter_oltp_endpoint            = var.aws_open_telemetry_emitter_oltp_endpoint
  aws_open_telemetry_mg_node_iam_role_arns            = var.aws_open_telemetry_mg_node_iam_role_arns
  aws_open_telemetry_self_mg_node_iam_role_arns       = var.aws_open_telemetry_self_mg_node_iam_role_arns
  aws_open_telemetry_emitter_name                     = var.aws_open_telemetry_emitter_name
  aws_open_telemetry_emitter_otel_resource_attributes = var.aws_open_telemetry_emitter_otel_resource_attributes
}

module "opentelemetry_collector" {
  count  = var.opentelemetry_enable == true ? 1 : 0
  source = "./opentelemetry-collector"

  private_container_repo_url                            = var.private_container_repo_url
  public_docker_repo                                    = var.public_docker_repo
  opentelemetry_command_name                            = var.opentelemetry_command_name
  opentelemetry_helm_chart                              = var.opentelemetry_helm_chart
  opentelemetry_helm_chart_url                          = var.opentelemetry_helm_chart_url
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
