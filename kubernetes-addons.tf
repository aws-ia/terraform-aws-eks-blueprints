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

module "agones" {
  count                        = var.create_eks && var.enable_agones ? 1 : 0
  source                       = "./kubernetes-addons/agones"
  helm_config                  = var.agones_helm_config
  eks_worker_security_group_id = module.aws_eks.worker_security_group_id
  manage_via_gitops            = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "argocd" {
  count               = var.create_eks && var.enable_argocd ? 1 : 0
  source              = "./kubernetes-addons/argocd"
  helm_config         = var.argocd_helm_config
  argocd_applications = var.argocd_applications
  eks_cluster_name    = module.aws_eks.cluster_id
  add_on_config       = local.argocd_add_on_config

  depends_on = [module.aws_eks]
}

module "aws_for_fluent_bit" {
  count             = var.create_eks && var.enable_aws_for_fluentbit ? 1 : 0
  source            = "./kubernetes-addons/aws-for-fluentbit"
  helm_config       = var.aws_for_fluentbit_helm_chart
  eks_cluster_id    = module.aws_eks.cluster_id
  manage_via_gitops = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "aws_load_balancer_controller" {
  count                 = var.create_eks && var.enable_aws_load_balancer_controller ? 1 : 0
  source                = "./kubernetes-addons/aws-load-balancer-controller"
  helm_config           = var.aws_load_balancer_controller_helm_config
  eks_cluster_id        = module.aws_eks.cluster_id
  eks_oidc_issuer_url   = module.aws_eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn = module.aws_eks.oidc_provider_arn
  manage_via_gitops     = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "aws_node_termination_handler" {
  count                   = var.create_eks && var.enable_aws_node_termination_handler && length(var.self_managed_node_groups) > 0 ? 1 : 0
  source                  = "./kubernetes-addons/aws-node-termination-handler"
  helm_config             = var.aws_node_termination_handler_helm_config
  eks_cluster_name        = module.aws_eks.cluster_id
  autoscaling_group_names = var.create_eks && length(var.self_managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.self_managed_node_groups)) : nodes => join(",", module.aws_eks_self_managed_node_groups[nodes].self_managed_asg_names) }) : []

  depends_on = [module.aws_eks]
}

module "aws_opentelemetry_collector" {
  count                      = var.create_eks && var.enable_aws_open_telemetry ? 1 : 0
  source                     = "./kubernetes-addons/aws-opentelemetry-eks"
  addon_config               = var.aws_open_telemetry_addon_config
  mg_node_iam_role_arns      = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.managed_node_groups)) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_role_name) }) : []
  self_mg_node_iam_role_arns = var.create_eks && length(var.self_managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.self_managed_node_groups)) : nodes => join(",", module.aws_eks_self_managed_node_groups[nodes].self_managed_node_group_iam_role_arns) }) : []
  manage_via_gitops          = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "cert_manager" {
  count             = var.create_eks && var.enable_cert_manager ? 1 : 0
  source            = "./kubernetes-addons/cert-manager"
  helm_config       = var.cert_manager_helm_config
  manage_via_gitops = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "cluster_autoscaler" {
  count             = var.create_eks && var.enable_cluster_autoscaler ? 1 : 0
  source            = "./kubernetes-addons/cluster-autoscaler"
  helm_config       = var.cluster_autoscaler_helm_config
  eks_cluster_id    = module.aws_eks.cluster_id
  manage_via_gitops = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "fargate_fluentbit" {
  count          = var.create_eks && var.enable_fargate_fluentbit ? 1 : 0
  source         = "./kubernetes-addons/fargate-fluentbit"
  eks_cluster_id = module.aws_eks.cluster_id
  addon_config   = var.fargate_fluentbit_addon_config

  depends_on = [module.aws_eks]
}

module "keda" {
  count             = var.create_eks && var.enable_keda ? 1 : 0
  source            = "./kubernetes-addons/keda"
  helm_config       = var.keda_helm_config
  eks_cluster_name  = module.aws_eks.cluster_id
  create_irsa       = var.keda_create_irsa
  irsa_policies     = var.keda_irsa_policies
  tags              = var.tags
  manage_via_gitops = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "metrics_server" {
  count             = var.create_eks && var.enable_metrics_server ? 1 : 0
  source            = "./kubernetes-addons/metrics-server"
  helm_config       = var.metrics_server_helm_config
  manage_via_gitops = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "ingress_nginx" {
  count             = var.create_eks && var.enable_ingress_nginx ? 1 : 0
  source            = "./kubernetes-addons/ingress-nginx"
  helm_config       = var.nginx_helm_config
  manage_via_gitops = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "prometheus" {
  count       = var.create_eks && var.enable_prometheus ? 1 : 0
  source      = "./kubernetes-addons/prometheus"
  helm_config = var.prometheus_helm_config

  #AWS Managed Prometheus Workspace
  aws_managed_prometheus_enable   = var.enable_aws_managed_prometheus
  amp_workspace_id                = var.enable_aws_managed_prometheus ? module.aws_managed_prometheus[0].amp_workspace_id : ""
  amp_ingest_role_arn             = var.enable_aws_managed_prometheus ? module.aws_managed_prometheus[0].service_account_amp_ingest_role_arn : ""
  service_account_amp_ingest_name = local.service_account_amp_ingest_name
  manage_via_gitops               = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "spark_on_k8s_operator" {
  count             = var.create_eks && var.enable_spark_on_k8s_operator ? 1 : 0
  source            = "./kubernetes-addons/spark-on-k8s-operator"
  helm_config       = var.spark_on_k8s_operator_helm_config
  manage_via_gitops = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "traefik" {
  count             = var.create_eks && var.enable_traefik ? 1 : 0
  source            = "./kubernetes-addons/traefik-ingress"
  helm_config       = var.traefik_helm_config
  manage_via_gitops = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}

module "vpa" {
  count       = var.create_eks && var.enable_vpa ? 1 : 0
  source      = "./kubernetes-addons/vpa"
  helm_config = var.vpa_helm_config

  depends_on = [module.aws_eks]
}

module "yunikorn" {
  count             = var.create_eks && var.enable_yunikorn ? 1 : 0
  source            = "./kubernetes-addons/yunikorn"
  helm_config       = var.yunikorn_helm_config
  manage_via_gitops = var.argocd_manage_add_ons

  depends_on = [module.aws_eks]
}
