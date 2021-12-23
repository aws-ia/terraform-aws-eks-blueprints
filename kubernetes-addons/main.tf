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

#-----------------AWS Managed EKS Add-ons----------------------

module "aws_vpc_cni" {
  count         = var.enable_amazon_eks_vpc_cni ? 1 : 0
  source        = "./aws-vpc-cni"
  add_on_config = var.amazon_eks_vpc_cni_config
  cluster_id    = local.eks_cluster_id
  common_tags   = var.tags
}

module "aws_coredns" {
  count         = var.enable_amazon_eks_coredns ? 1 : 0
  source        = "./aws-coredns"
  add_on_config = var.amazon_eks_coredns_config
  cluster_id    = local.eks_cluster_id
  common_tags   = var.tags
}

module "aws_kube_proxy" {
  count         = var.enable_amazon_eks_kube_proxy ? 1 : 0
  source        = "./aws-kube-proxy"
  add_on_config = var.amazon_eks_kube_proxy_config
  cluster_id    = local.eks_cluster_id
  common_tags   = var.tags
}

module "aws_ebs_csi_driver" {
  count         = var.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0
  source        = "./aws-ebs-csi-driver"
  add_on_config = var.amazon_eks_aws_ebs_csi_driver_config
  cluster_id    = local.eks_cluster_id
  common_tags   = var.tags
}

#-----------------Kubernetes Add-ons----------------------
module "agones" {
  count                        = var.enable_agones ? 1 : 0
  source                       = "./agones"
  helm_config                  = var.agones_helm_config
  eks_worker_security_group_id = var.eks_worker_security_group_id
  manage_via_gitops            = var.argocd_manage_add_ons
}

module "argocd" {
  count               = var.enable_argocd ? 1 : 0
  source              = "./argocd"
  helm_config         = var.argocd_helm_config
  argocd_applications = var.argocd_applications
  eks_cluster_name    = local.eks_cluster_id
  add_on_config       = local.argocd_add_on_config
}

module "aws_for_fluent_bit" {
  count             = var.enable_aws_for_fluentbit ? 1 : 0
  source            = "./aws-for-fluentbit"
  helm_config       = var.aws_for_fluentbit_helm_config
  eks_cluster_id    = local.eks_cluster_id
  manage_via_gitops = var.argocd_manage_add_ons
}

module "aws_load_balancer_controller" {
  count                 = var.enable_aws_load_balancer_controller ? 1 : 0
  source                = "./aws-load-balancer-controller"
  helm_config           = var.aws_load_balancer_controller_helm_config
  eks_cluster_id        = local.eks_cluster_id
  eks_oidc_issuer_url   = var.eks_cluster_oidc_url
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
  manage_via_gitops     = var.argocd_manage_add_ons
}

module "aws_node_termination_handler" {
  count  = var.enable_aws_node_termination_handler && length(var.auto_scaling_group_names) > 0 ? 1 : 0
  source = "./aws-node-termination-handler"

  eks_cluster_name        = local.eks_cluster_id
  helm_config             = var.aws_node_termination_handler_helm_config
  autoscaling_group_names = var.auto_scaling_group_names
}

module "aws_opentelemetry_collector" {
  count  = var.enable_aws_open_telemetry ? 1 : 0
  source = "./aws-opentelemetry-eks"

  addon_config             = var.aws_open_telemetry_addon_config
  node_groups_iam_role_arn = var.node_groups_iam_role_arn
  manage_via_gitops        = var.argocd_manage_add_ons
}

module "cert_manager" {
  count             = var.enable_cert_manager ? 1 : 0
  source            = "./cert-manager"
  helm_config       = var.cert_manager_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
}

module "cluster_autoscaler" {
  count             = var.enable_cluster_autoscaler ? 1 : 0
  source            = "./cluster-autoscaler"
  helm_config       = var.cluster_autoscaler_helm_config
  eks_cluster_id    = local.eks_cluster_id
  manage_via_gitops = var.argocd_manage_add_ons
}

module "fargate_fluentbit" {
  count          = var.enable_fargate_fluentbit ? 1 : 0
  source         = "./fargate-fluentbit"
  eks_cluster_id = local.eks_cluster_id
  addon_config   = var.fargate_fluentbit_addon_config
}

module "ingress_nginx" {
  count             = var.enable_ingress_nginx ? 1 : 0
  source            = "./ingress-nginx"
  helm_config       = var.nginx_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
}

module "keda" {
  count             = var.enable_keda ? 1 : 0
  source            = "./keda"
  helm_config       = var.keda_helm_config
  eks_cluster_name  = local.eks_cluster_id
  create_irsa       = var.keda_create_irsa
  irsa_policies     = var.keda_irsa_policies
  tags              = var.tags
  manage_via_gitops = var.argocd_manage_add_ons
}

module "metrics_server" {
  count             = var.enable_metrics_server ? 1 : 0
  source            = "./metrics-server"
  helm_config       = var.metrics_server_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
}

module "prometheus" {
  count       = var.enable_prometheus ? 1 : 0
  source      = "./prometheus"
  helm_config = var.prometheus_helm_config

  #AWS Managed Prometheus Workspace
  enable_aws_managed_prometheus   = var.enable_aws_managed_prometheus
  amp_workspace_id                = var.aws_managed_prometheus_workspace_id
  amp_ingest_role_arn             = var.aws_managed_prometheus_ingest_iam_role_arn
  service_account_amp_ingest_name = var.aws_managed_prometheus_ingest_service_account
  manage_via_gitops               = var.argocd_manage_add_ons
}

module "spark_on_k8s_operator" {
  count             = var.enable_spark_on_k8s_operator ? 1 : 0
  source            = "./spark-on-k8s-operator"
  helm_config       = var.spark_on_k8s_operator_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
}

module "traefik_ingress" {
  count             = var.enable_traefik ? 1 : 0
  source            = "./traefik"
  helm_config       = var.traefik_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
}

module "vpa" {
  count       = var.enable_vpa ? 1 : 0
  source      = "./vpa"
  helm_config = var.vpa_helm_config
}

module "yunikorn" {
  count             = var.enable_yunikorn ? 1 : 0
  source            = "./yunikorn"
  helm_config       = var.yunikorn_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
}
