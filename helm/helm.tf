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
  count              = var.metrics_server_enable == true ? 1 : 0
  source             = "./metrics_server"
  image_repo_url     = var.image_repo_url
  public_docker_repo = var.public_docker_repo
}

module "cluster_autoscaler" {
  count              = var.cluster_autoscaler_enable == true ? 1 : 0
  source             = "./cluster_autoscaler"
  image_repo_url     = var.image_repo_url
  eks_cluster_id     = var.eks_cluster_id
  public_docker_repo = var.public_docker_repo
}

module "lb_ingress_controller" {
  count                 = var.lb_ingress_controller_enable == true ? 1 : 0
  source                = "./lb_ingress_controller"
  image_repo_url        = var.image_repo_url
  clusterName           = var.eks_cluster_id
  eks_oidc_issuer_url   = var.eks_oidc_issuer_url
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
  public_docker_repo    = var.public_docker_repo
}

module "traefik_ingress" {
  count              = var.traefik_ingress_controller_enable == true ? 1 : 0
  source             = "./traefik_ingress"
  image_repo_url     = var.image_repo_url
  account_id         = data.aws_caller_identity.current.account_id
  s3_nlb_logs        = var.s3_nlb_logs
  public_docker_repo = var.public_docker_repo
  //  tls_cert_arn = ""
}

module "aws-for-fluent-bit" {
  count                    = var.aws_for_fluent_bit_enable == true ? 1 : 0
  source                   = "./aws-for-fluent-bit"
  image_repo_url           = var.image_repo_url
  cluster_id               = var.eks_cluster_id
  ekslog_retention_in_days = var.ekslog_retention_in_days
  public_docker_repo       = var.public_docker_repo
}

module "fargate_fluentbit" {
  source           = "./fargate_fluentbit"
  eks_cluster_id   = var.eks_cluster_id
  fargate_iam_role = var.fargate_iam_role
}