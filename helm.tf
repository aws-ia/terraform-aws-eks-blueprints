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
module "helm" {
  # count        = var.create_eks ? 1 : 0
  source                     = "./helm"
  eks_cluster_id             = module.eks.eks_cluster_id
  public_docker_repo         = var.public_docker_repo
  private_container_repo_url = local.image_repo

  # ------- Cluster Autoscaler
  cluster_autoscaler_enable       = var.cluster_autoscaler_enable
  cluster_autoscaler_image_tag    = var.cluster_autoscaler_image_tag
  cluster_autoscaler_helm_version = var.cluster_autoscaler_helm_version

  # ------- Metric Server
  metrics_server_enable            = var.metrics_server_enable
  metric_server_image_tag          = var.metric_server_image_tag
  metric_server_helm_chart_version = var.metric_server_helm_chart_version

  # ------- Traefik Ingress Controller
  traefik_ingress_controller_enable = var.traefik_ingress_controller_enable
  s3_nlb_logs                       = module.s3.s3_bucket_name
  traefik_helm_chart_version        = var.traefik_helm_chart_version
  traefik_image_tag                 = var.traefik_image_tag

  # ------- AWS LB Controller
  lb_ingress_controller_enable = var.lb_ingress_controller_enable
  aws_lb_image_tag             = var.aws_lb_image_tag
  aws_lb_helm_chart_version    = var.aws_lb_helm_chart_version
  eks_oidc_issuer_url          = module.eks.eks_cluster_oidc_issuer_url
  eks_oidc_provider_arn        = module.eks.oidc_provider_arn

  # ------- Nginx Ingress Controller
  nginx_ingress_controller_enable = var.nginx_ingress_controller_enable
  nginx_helm_chart_version        = var.nginx_helm_chart_version
  nginx_image_tag                 = var.nginx_image_tag

  # ------- AWS Fluent bit for Node Groups
  aws_for_fluent_bit_enable             = var.aws_for_fluent_bit_enable
  ekslog_retention_in_days              = var.ekslog_retention_in_days
  aws_for_fluent_bit_image_tag          = var.aws_for_fluent_bit_image_tag
  aws_for_fluent_bit_helm_chart_version = var.aws_for_fluent_bit_helm_chart_version

  # ------- AWS Fluentbit for Fargate
  fargate_fluent_bit_enable   = var.enable_fargate ? var.fargate_fluent_bit_enable : false

  # ------- Agones Gaming Module ---------
  agones_enable         = var.agones_enable
  expose_udp            = var.expose_udp
  eks_security_group_id = module.eks.eks_worker_security_group_id

  # ------- Prometheus Module ---------
  prometheus_enable               = var.prometheus_enable
  alert_manager_image_tag         = var.alert_manager_image_tag
  configmap_reload_image_tag      = var.configmap_reload_image_tag
  node_exporter_image_tag         = var.node_exporter_image_tag
  prometheus_helm_chart_version   = var.prometheus_helm_chart_version
  prometheus_image_tag            = var.prometheus_image_tag
  pushgateway_image_tag           = var.pushgateway_image_tag
  amp_ingest_role_arn             = var.prometheus_enable ? module.aws_managed_prometheus[0].service_account_amp_ingest_role_arn : ""
  service_account_amp_ingest_name = local.service_account_amp_ingest_name
  amp_workspace_id                = var.prometheus_enable ? module.aws_managed_prometheus[0].amp_workspace_id : ""
  region                          = data.aws_region.current.id

  # ------- Cert Manager ---------
  # Cert Manager is a pre-requisite for Windows support
  cert_manager_enable             = var.cert_manager_enable || var.enable_windows_support
  cert_manager_image_tag          = var.cert_manager_image_tag
  cert_manager_helm_chart_version = var.cert_manager_helm_chart_version
  cert_manager_install_crds       = var.cert_manager_install_crds

  # ------- Windows VPC Controllers ---------
  windows_vpc_controllers_enable            = var.enable_windows_support
  windows_vpc_resource_controller_image_tag = var.windows_vpc_resource_controller_image_tag
  windows_vpc_admission_webhook_image_tag   = var.windows_vpc_admission_webhook_image_tag

  depends_on = [module.eks]
}