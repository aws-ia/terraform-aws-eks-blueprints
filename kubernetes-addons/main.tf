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
  count         = var.enable_eks_addon_vpc_cni ? 1 : 0
  source        = "./aws-vpc-cni"
  add_on_config = var.eks_addon_vpc_cni_config
  cluster_id    = local.eks_cluster_id
  common_tags   = var.tags
}

module "aws_coredns" {
  count         = var.enable_eks_addon_coredns ? 1 : 0
  source        = "./aws-coredns"
  add_on_config = var.eks_addon_coredns_config
  cluster_id    = local.eks_cluster_id
  common_tags   = var.tags
}

module "aws_kube_proxy" {
  count         = var.enable_eks_addon_kube_proxy ? 1 : 0
  source        = "./aws-kube-proxy"
  add_on_config = var.eks_addon_kube_proxy_config
  cluster_id    = local.eks_cluster_id
  common_tags   = var.tags
}

module "aws_ebs_csi_driver" {
  count         = var.amazon_eks_ebs_csi_driver_enable ? 1 : 0
  source        = "./aws-ebs-csi-driver"
  add_on_config = var.amazon_eks_ebs_csi_driver_config
  cluster_id    = local.eks_cluster_id
  common_tags   = var.tags
}

#-----------------Kubernetes Add-ons----------------------
module "agones" {
  count                        = var.agones_enable ? 1 : 0
  source                       = "./agones"
  helm_provider_config         = var.agones_helm_chart
  eks_worker_security_group_id = var.eks_worker_security_group_id
  manage_via_gitops            = var.argocd_manage_add_ons
}

module "argocd" {
  count                = var.argocd_enable ? 1 : 0
  source               = "./argocd"
  helm_provider_config = var.argocd_helm_chart
  argocd_applications  = var.argocd_applications
  eks_cluster_name     = local.eks_cluster_id
  add_on_config        = local.argocd_add_on_config
}

module "aws_for_fluent_bit" {
  count                = var.aws_for_fluentbit_enable ? 1 : 0
  source               = "./aws-for-fluentbit"
  helm_provider_config = var.aws_for_fluentbit_helm_chart
  eks_cluster_id       = local.eks_cluster_id
  manage_via_gitops    = var.argocd_manage_add_ons
}

module "aws_load_balancer_controller" {
  count                 = var.aws_lb_ingress_controller_enable ? 1 : 0
  source                = "./aws-load-balancer-controller"
  helm_provider_config  = var.aws_lb_ingress_controller_helm_chart
  eks_cluster_id        = local.eks_cluster_id
  eks_oidc_issuer_url   = var.eks_cluster_oidc_url
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
  manage_via_gitops     = var.argocd_manage_add_ons
}

module "aws_node_termination_handler" {
  count  = var.aws_node_termination_handler_enable && length(var.auto_scaling_group_names) > 0 ? 1 : 0
  source = "./aws-node-termination-handler"

  eks_cluster_name        = local.eks_cluster_id
  helm_provider_config    = var.aws_node_termination_handler_helm_chart
  autoscaling_group_names = var.auto_scaling_group_names
}

module "aws_opentelemetry_collector" {
  count  = var.aws_open_telemetry_enable ? 1 : 0
  source = "./aws-opentelemetry-eks"

  addon_config             = var.aws_open_telemetry_addon
  node_groups_iam_role_arn = var.node_groups_iam_role_arn
  manage_via_gitops        = var.argocd_manage_add_ons
}

module "cert_manager" {
  count                = var.cert_manager_enable ? 1 : 0
  source               = "./cert-manager"
  helm_provider_config = var.cert_manager_helm_chart
  manage_via_gitops    = var.argocd_manage_add_ons
}

module "cluster_autoscaler" {
  count                = var.cluster_autoscaler_enable ? 1 : 0
  source               = "./cluster-autoscaler"
  helm_provider_config = var.cluster_autoscaler_helm_chart
  eks_cluster_id       = local.eks_cluster_id
  manage_via_gitops    = var.argocd_manage_add_ons
}

module "fargate_fluentbit" {
  count                    = var.fargate_fluentbit_enable ? 1 : 0
  source                   = "./fargate-fluentbit"
  eks_cluster_id           = local.eks_cluster_id
  fargate_fluentbit_config = var.fargate_fluentbit_config
}

module "ingress_nginx" {
  count                = var.ingress_nginx_controller_enable ? 1 : 0
  source               = "./ingress-nginx"
  helm_provider_config = var.nginx_helm_chart
  manage_via_gitops    = var.argocd_manage_add_ons
}

module "keda" {
  count                = var.keda_enable ? 1 : 0
  source               = "./keda"
  helm_provider_config = var.keda_helm_chart
  eks_cluster_name     = local.eks_cluster_id
  create_irsa          = var.keda_create_irsa
  irsa_policies        = var.keda_irsa_policies
  tags                 = var.tags
  manage_via_gitops    = var.argocd_manage_add_ons
}

module "metrics_server" {
  count                = var.metrics_server_enable ? 1 : 0
  source               = "./metrics-server"
  helm_provider_config = var.metrics_server_helm_chart
  manage_via_gitops    = var.argocd_manage_add_ons
}

module "prometheus" {
  count                = var.prometheus_enable ? 1 : 0
  source               = "./prometheus"
  helm_provider_config = var.prometheus_helm_chart

  #AWS Managed Prometheus Workspace
  aws_managed_prometheus_enable   = var.aws_managed_prometheus_enable
  amp_workspace_id                = var.aws_managed_prometheus_workspace_id
  amp_ingest_role_arn             = var.aws_managed_prometheus_ingest_iam_role_arn
  service_account_amp_ingest_name = var.aws_managed_prometheus_ingest_service_account
  manage_via_gitops               = var.argocd_manage_add_ons
}

module "spark_k8s_operator" {
  count                = var.spark_on_k8s_operator_enable ? 1 : 0
  source               = "./spark-k8s-operator"
  helm_provider_config = var.spark_on_k8s_operator_helm_chart
  manage_via_gitops    = var.argocd_manage_add_ons
}

module "traefik_ingress" {
  count                = var.traefik_ingress_controller_enable ? 1 : 0
  source               = "./traefik-ingress"
  helm_provider_config = var.traefik_helm_chart
  manage_via_gitops    = var.argocd_manage_add_ons
}

module "vpa" {
  count                = var.vpa_enable ? 1 : 0
  source               = "./vertical-pod-autoscaler"
  helm_provider_config = var.vpa_helm_chart
}

module "yunikorn" {
  count                = var.yunikorn_enable ? 1 : 0
  source               = "./yunikorn"
  helm_provider_config = var.yunikorn_helm_chart
  manage_via_gitops    = var.argocd_manage_add_ons
}
