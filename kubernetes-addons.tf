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
  count                     = var.create_eks && var.metrics_server_enable ? 1 : 0
  source                    = "./kubernetes-addons/metrics-server"
  metrics_server_helm_chart = var.metrics_server_helm_chart

  depends_on = [module.aws_eks]
}

module "cluster_autoscaler" {
  count                         = var.create_eks && var.cluster_autoscaler_enable ? 1 : 0
  source                        = "./kubernetes-addons/cluster-autoscaler"
  eks_cluster_id                = module.aws_eks.cluster_id
  cluster_autoscaler_helm_chart = var.cluster_autoscaler_helm_chart

  depends_on = [module.aws_eks]
}

module "traefik_ingress" {
  count              = var.create_eks && var.traefik_ingress_controller_enable ? 1 : 0
  source             = "./kubernetes-addons/traefik-ingress"
  traefik_helm_chart = var.traefik_helm_chart

  depends_on = [module.aws_eks]
}

module "prometheus" {
  count                 = var.create_eks && var.prometheus_enable ? 1 : 0
  source                = "./kubernetes-addons/prometheus"
  prometheus_helm_chart = var.prometheus_helm_chart
  #AWS Managed Prometheus Workspace
  aws_managed_prometheus_enable   = var.aws_managed_prometheus_enable
  amp_workspace_id                = var.aws_managed_prometheus_enable ? module.aws_managed_prometheus[0].amp_workspace_id : ""
  amp_ingest_role_arn             = var.aws_managed_prometheus_enable ? module.aws_managed_prometheus[0].service_account_amp_ingest_role_arn : ""
  service_account_amp_ingest_name = local.service_account_amp_ingest_name

  depends_on = [module.aws_eks]
}

# TODO Upgrade
module "lb_ingress_controller" {
  count  = var.create_eks && var.aws_lb_ingress_controller_enable ? 1 : 0
  source = "./kubernetes-addons/lb-ingress-controller"

  private_container_repo_url  = var.private_container_repo_url
  clusterName                 = module.aws_eks.cluster_id
  eks_oidc_issuer_url         = module.aws_eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn       = module.aws_eks.oidc_provider_arn
  public_docker_repo          = var.public_docker_repo
  aws_lb_image_tag            = var.aws_lb_image_tag
  aws_lb_helm_chart_version   = var.aws_lb_helm_chart_version
  aws_lb_image_repo_name      = var.aws_lb_image_repo_name
  aws_lb_helm_repo_url        = var.aws_lb_helm_repo_url
  aws_lb_helm_helm_chart_name = var.aws_lb_helm_helm_chart_name

  depends_on = [module.aws_eks]
}

module "nginx_ingress" {
  count            = var.create_eks && var.nginx_ingress_controller_enable ? 1 : 0
  source           = "./kubernetes-addons/nginx-ingress"
  nginx_helm_chart = var.nginx_helm_chart

  depends_on = [module.aws_eks]
}


module "aws-for-fluent-bit" {
  count                                       = var.create_eks && var.aws_for_fluent_bit_enable ? 1 : 0
  source                                      = "./kubernetes-addons/aws-for-fluent-bit"
  aws_for_fluent_bit_cw_log_retention_in_days = var.aws_for_fluent_bit_cw_log_retention_in_days
  aws_for_fluent_bit_cw_log_group             = var.aws_for_fluent_bit_cw_log_group
  aws_for_fluent_bit_helm_chart               = var.aws_for_fluent_bit_helm_chart

  depends_on = [module.aws_eks]
}

module "fargate_fluentbit" {
  count                    = var.create_eks && var.fargate_fluentbit_enable ? 1 : 0
  source                   = "./kubernetes-addons/fargate-fluentbit"
  eks_cluster_id           = module.aws_eks.cluster_id
  fargate_fluentbit_config = var.fargate_fluentbit_config

  depends_on = [module.aws_eks]
}

module "agones" {
  count  = var.create_eks && var.agones_enable ? 1 : 0
  source = "./kubernetes-addons/agones"

  eks_worker_security_group_id = module.aws_eks.worker_security_group_id

  depends_on = [module.aws_eks]
}

# TODO Upgrade
module "cert_manager" {
  count  = var.create_eks && var.cert_manager_enable ? 1 : 0
  source = "./kubernetes-addons/cert-manager"

  private_container_repo_url      = var.private_container_repo_url
  public_docker_repo              = var.public_docker_repo
  cert_manager_helm_chart_version = var.cert_manager_helm_chart_version
  cert_manager_image_tag          = var.cert_manager_image_tag
  cert_manager_install_crds       = var.cert_manager_install_crds
  cert_manager_helm_chart_name    = var.cert_manager_helm_chart_name
  cert_manager_helm_chart_url     = var.cert_manager_helm_chart_url
  cert_manager_image_repo_name    = var.cert_manager_image_repo_name

  depends_on = [module.aws_eks]
}

# TODO Upgrade
module "windows_vpc_controllers" {
  count  = var.create_eks && var.enable_windows_support ? 1 : 0
  source = "./kubernetes-addons/windows-vpc-controllers"

  private_container_repo_url    = var.private_container_repo_url
  public_docker_repo            = var.public_docker_repo
  resource_controller_image_tag = var.windows_vpc_resource_controller_image_tag
  admission_webhook_image_tag   = var.windows_vpc_admission_webhook_image_tag
  depends_on = [
    module.cert_manager, module.aws_eks
  ]
}

module "aws_opentelemetry_collector" {
  count  = var.create_eks && var.aws_open_telemetry_enable ? 1 : 0
  source = "./kubernetes-addons/aws-opentelemetry-eks"

  aws_open_telemetry_addon                      = var.aws_open_telemetry_addon
  aws_open_telemetry_mg_node_iam_role_arns      = var.create_eks && var.enable_managed_nodegroups ? values({ for nodes in sort(keys(var.managed_node_groups)) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_role_name) }) : []
  aws_open_telemetry_self_mg_node_iam_role_arns = var.create_eks && var.enable_self_managed_nodegroups ? values({ for nodes in sort(keys(var.self_managed_node_groups)) : nodes => join(",", module.aws_eks_self_managed_node_groups[nodes].self_managed_node_group_iam_role_arns) }) : []

  depends_on = [module.aws_eks]
}

# TODO Upgrade
module "opentelemetry_collector" {
  count  = var.create_eks && var.opentelemetry_enable ? 1 : 0
  source = "./kubernetes-addons/opentelemetry-collector"

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

  depends_on = [module.aws_eks]
}
