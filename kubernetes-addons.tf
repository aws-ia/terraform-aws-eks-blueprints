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
  count                        = var.create_eks && var.aws_for_fluentbit_enable ? 1 : 0
  source                       = "./kubernetes-addons/aws-for-fluentbit"
  aws_for_fluentbit_helm_chart = var.aws_for_fluentbit_helm_chart
  eks_cluster_id               = module.aws_eks.cluster_id

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
  count                        = var.create_eks && var.agones_enable ? 1 : 0
  source                       = "./kubernetes-addons/agones"
  agones_helm_chart            = var.agones_helm_chart
  eks_worker_security_group_id = module.aws_eks.worker_security_group_id

  depends_on = [module.aws_eks]
}

module "spark-k8s-operator" {
  count                            = var.create_eks && var.spark_on_k8s_operator_enable ? 1 : 0
  source                           = "./kubernetes-addons/spark-k8s-operator"
  spark_on_k8s_operator_helm_chart = var.spark_on_k8s_operator_helm_chart

  depends_on = [module.aws_eks]
}

module "cert_manager" {
  count  = var.create_eks && (var.cert_manager_enable || var.enable_windows_support) ? 1 : 0
  source = "./kubernetes-addons/cert-manager"

  cert_manager_helm_chart = var.cert_manager_helm_chart

  depends_on = [module.aws_eks]
}

module "windows_vpc_controllers" {
  count  = var.create_eks && var.enable_windows_support ? 1 : 0
  source = "./kubernetes-addons/windows-vpc-controllers"

  windows_vpc_controllers_helm_chart = var.windows_vpc_controllers_helm_chart

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
