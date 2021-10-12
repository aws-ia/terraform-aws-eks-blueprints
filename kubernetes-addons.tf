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

# ---------------------------------------------------------------------------------------------------------------------
# Invoking Helm Module
# ---------------------------------------------------------------------------------------------------------------------
module "kubernetes_addons" {
  count = var.create_eks ? 1 : 0

  source                     = "./kubernetes-addons"
  eks_cluster_id             = module.aws_eks.cluster_id
  public_docker_repo         = var.public_docker_repo
  private_container_repo_url = var.private_container_repo_url != "" ? var.private_container_repo_url : local.ecr_image_repo_url

  # ------- Traefik Ingress Controller
  traefik_ingress_controller_enable = var.traefik_ingress_controller_enable
  traefik_helm_chart                = var.traefik_helm_chart

  # ------- Cluster Autoscaler
  cluster_autoscaler_enable          = var.cluster_autoscaler_enable
  cluster_autoscaler_image_tag       = var.cluster_autoscaler_image_tag
  cluster_autoscaler_helm_version    = var.cluster_autoscaler_helm_version
  cluster_autoscaler_helm_repo_url   = var.cluster_autoscaler_helm_repo_url
  cluster_autoscaler_helm_chart_name = var.cluster_autoscaler_helm_chart_name
  cluster_autoscaler_image_repo_name = var.cluster_autoscaler_image_repo_name

  # ------- Metric Server
  metrics_server_enable     = var.metrics_server_enable
  metrics_server_helm_chart = var.metrics_server_helm_chart

  # ------- AWS LB Controller
  aws_lb_ingress_controller_enable = var.aws_lb_ingress_controller_enable
  aws_lb_image_tag                 = var.aws_lb_image_tag
  aws_lb_helm_chart_version        = var.aws_lb_helm_chart_version
  eks_oidc_issuer_url              = module.aws_eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn            = module.aws_eks.oidc_provider_arn
  aws_lb_helm_repo_url             = var.aws_lb_helm_repo_url
  aws_lb_helm_helm_chart_name      = var.aws_lb_helm_helm_chart_name
  aws_lb_image_repo_name           = var.aws_lb_image_repo_name

  # ------- Nginx Ingress Controller
  nginx_ingress_controller_enable = var.nginx_ingress_controller_enable
  nginx_helm_chart_version        = var.nginx_helm_chart_version
  nginx_image_tag                 = var.nginx_image_tag
  nginx_helm_chart_url            = var.nginx_helm_chart_url
  nginx_helm_chart_name           = var.nginx_helm_chart_name
  nginx_image_repo_name           = var.nginx_image_repo_name

  # ------- AWS Fluent bit for Node Groups
  aws_for_fluent_bit_enable             = var.aws_for_fluent_bit_enable
  ekslog_retention_in_days              = var.ekslog_retention_in_days
  aws_for_fluent_bit_image_tag          = var.aws_for_fluent_bit_image_tag
  aws_for_fluent_bit_helm_chart_version = var.aws_for_fluent_bit_helm_chart_version
  aws_for_fluent_bit_helm_chart_url     = var.aws_for_fluent_bit_helm_chart_url
  aws_for_fluent_bit_helm_chart_name    = var.aws_for_fluent_bit_helm_chart_name
  aws_for_fluent_bit_image_repo_name    = var.aws_for_fluent_bit_image_repo_name


  # ------- AWS Fluentbit for Fargate
  fargate_fluent_bit_enable = var.enable_fargate ? var.fargate_fluent_bit_enable : false

  # ------- Agones Gaming Module ---------
  agones_enable              = var.agones_enable
  expose_udp                 = var.expose_udp
  eks_security_group_id      = module.aws_eks.worker_security_group_id
  agones_helm_chart_name     = var.agones_helm_chart_name
  agones_helm_chart_url      = var.agones_helm_chart_url
  agones_image_tag           = var.agones_image_tag
  agones_image_repo          = var.agones_image_repo
  agones_game_server_minport = var.agones_game_server_minport
  agones_game_server_maxport = var.agones_game_server_maxport

  # ------- Prometheus Module ---------
  prometheus_enable               = var.prometheus_enable
  alert_manager_image_tag         = var.alert_manager_image_tag
  configmap_reload_image_tag      = var.configmap_reload_image_tag
  node_exporter_image_tag         = var.node_exporter_image_tag
  prometheus_helm_chart_version   = var.prometheus_helm_chart_version
  prometheus_image_tag            = var.prometheus_image_tag
  pushgateway_image_tag           = var.pushgateway_image_tag
  amp_ingest_role_arn             = var.prometheus_enable ? module.aws_managed_prometheus[0].service_account_amp_ingest_role_arn : ""
  service_account_amp_ingest_name = format("%s-%s", module.aws_eks.cluster_id, "amp-ingest-account")
  amp_workspace_id                = var.prometheus_enable ? module.aws_managed_prometheus[0].amp_workspace_id : ""
  region                          = data.aws_region.current.id
  prometheus_helm_chart_url       = var.prometheus_helm_chart_url
  prometheus_helm_chart_name      = var.prometheus_helm_chart_name

  # ------- Cert Manager ---------
  # Cert Manager is a pre-requisite for Windows support
  cert_manager_enable             = var.cert_manager_enable || var.enable_windows_support
  cert_manager_image_tag          = var.cert_manager_image_tag
  cert_manager_helm_chart_version = var.cert_manager_helm_chart_version
  cert_manager_install_crds       = var.cert_manager_install_crds
  cert_manager_helm_chart_name    = var.cert_manager_helm_chart_name
  cert_manager_helm_chart_url     = var.cert_manager_helm_chart_url
  cert_manager_image_repo_name    = var.cert_manager_image_repo_name

  # ------- Windows VPC Controllers ---------
  windows_vpc_controllers_enable            = var.enable_windows_support
  windows_vpc_resource_controller_image_tag = var.windows_vpc_resource_controller_image_tag
  windows_vpc_admission_webhook_image_tag   = var.windows_vpc_admission_webhook_image_tag

  # ------- AWS Distro for OpenTelemetry Collector in EKS Module ---------
  aws_open_telemetry_enable                           = var.aws_open_telemetry_enable
  aws_open_telemetry_namespace                        = var.aws_open_telemetry_namespace
  aws_open_telemetry_aws_region                       = var.aws_open_telemetry_aws_region
  aws_open_telemetry_collector_image                  = var.aws_open_telemetry_collector_image
  aws_open_telemetry_emitter_image                    = var.aws_open_telemetry_emitter_image
  aws_open_telemetry_emitter_oltp_endpoint            = var.aws_open_telemetry_emitter_oltp_endpoint
  aws_open_telemetry_mg_node_iam_role_arns            = var.create_eks && var.enable_managed_nodegroups ? values({ for nodes in sort(keys(var.managed_node_groups)) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_role_name) }) : []
  aws_open_telemetry_self_mg_node_iam_role_arns       = var.create_eks && var.enable_self_managed_nodegroups ? values({ for nodes in sort(keys(var.self_managed_node_groups)) : nodes => join(",", module.aws_eks_self_managed_node_groups[nodes].self_managed_iam_role_name) }) : []
  aws_open_telemetry_emitter_name                     = var.aws_open_telemetry_emitter_name
  aws_open_telemetry_emitter_otel_resource_attributes = var.aws_open_telemetry_emitter_otel_resource_attributes

  # ------- OpenTelemetry Module ---------
  opentelemetry_enable                                  = var.opentelemetry_enable
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
  opentelemetry_helm_chart_url                          = var.opentelemetry_helm_chart_url


  depends_on = [module.aws_eks]

}
