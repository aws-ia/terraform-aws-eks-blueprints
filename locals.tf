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

locals {

  tags = tomap({ "created-by" = var.terraform_version })

  ecr_image_repo_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com"

  # Managed node IAM Roles for aws-auth
  managed_node_group_aws_auth_config_map = length(var.managed_node_groups) > 0 == true ? [
    for key, node in var.managed_node_groups : {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}"
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ] : []

  # Self Managed node IAM Roles for aws-auth
  self_managed_node_group_aws_auth_config_map = length(var.self_managed_node_groups) > 0 ? [
    for key, node in var.self_managed_node_groups : {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}"
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    } if node.launch_template_os != "windows"
  ] : []

  # Self Managed Windows node IAM Roles for aws-auth
  windows_node_group_aws_auth_config_map = length(var.self_managed_node_groups) > 0 && var.enable_windows_support ? [
    for key, node in var.self_managed_node_groups : {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}"
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        "eks:kube-proxy-windows"
      ]
    } if node.launch_template_os == "windows"
  ] : []

  # Fargate node IAM Roles for aws-auth
  fargate_profiles_aws_auth_config_map = length(var.fargate_profiles) > 0 ? [
    for key, node in var.fargate_profiles : {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.fargate_profile_name}"
      username : "system:node:{{SessionName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        "system:node-proxier"
      ]
    }
  ] : []

  # EMR on EKS IAM Roles for aws-auth
  emr_on_eks_config_map = var.enable_emr_on_eks == true ? [
    {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/AWSServiceRoleForAmazonEMRContainers"
      username : "emr-containers"
      groups : []
    }
  ] : []
  platform_teams_config_map       = module.aws_eks_teams.platform_teams_config_map
  application_teams_config_map    = module.aws_eks_teams.application_teams_config_map
  service_account_amp_ingest_name = format("%s-%s", module.aws_eks.cluster_id, "amp-ingest")
  service_account_amp_query_name  = format("%s-%s", module.aws_eks.cluster_id, "amp-query")

  # Configuration for managing add-ons via ArgoCD.
  argocd_add_on_config = {
    agones                    = var.agones_enable ? module.agones[0].argocd_gitops_config : null
    awsForFluentBit           = var.aws_for_fluentbit_enable ? module.aws_for_fluent_bit[0].argocd_gitops_config : null
    awsLoadBalancerController = var.aws_lb_ingress_controller_enable ? module.aws_load_balancer_controller[0].argocd_gitops_config : null
    awsOtelCollector          = var.aws_open_telemetry_enable ? module.aws_opentelemetry_collector[0].argocd_gitops_config : null
    certManager               = var.cert_manager_enable ? module.cert_manager[0].argocd_gitops_config : null
    clusterAutoscaler         = var.cluster_autoscaler_enable ? module.cluster_autoscaler[0].argocd_gitops_config : null
    ingressNginx              = var.nginx_ingress_controller_enable ? module.nginx_ingress[0].argocd_gitops_config : null
    keda                      = var.keda_enable ? module.keda[0].argocd_gitops_config : null
    metricsServer             = var.metrics_server_enable ? module.metrics_server[0].argocd_gitops_config : null
    nginxIngress              = var.nginx_ingress_controller_enable ? module.nginx_ingress[0].argocd_gitops_config : null
    prometheus                = var.prometheus_enable ? module.prometheus[0].argocd_gitops_config : null
    sparkOperator             = var.spark_on_k8s_operator_enable ? module.spark-k8s-operator[0].argocd_gitops_config : null
    traefik                   = var.traefik_ingress_controller_enable ? module.traefik_ingress[0].argocd_gitops_config : null
  }
}
