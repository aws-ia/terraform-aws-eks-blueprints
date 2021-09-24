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
# LABELING EKS RESOURCES
# ---------------------------------------------------------------------------------------------------------------------
module "eks-label" {
  source      = "./modules/aws-resource-label"
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  resource    = "eks"
  tags        = local.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS CONTROL PLANE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
}

module "eks" {
  source = "git@github.com:maheshr-amzn/terraform-aws-eks_cluster?ref=feature/aws-eks_cluster-development"
  # version = ???

  create_eks      = var.create_eks
  manage_aws_auth = false # Replaced by the auth.tf file

  eks_cluster_name    = module.eks-label.id
  eks_cluster_version = var.kubernetes_version

  # NETWORK CONFIG
  vpc_id  = var.create_vpc == false ? var.vpc_id : module.vpc.vpc_id
  subnets = var.create_vpc == false ? var.private_subnet_ids : module.vpc.private_subnets

  eks_cluster_endpoint_private_access = var.endpoint_private_access
  eks_cluster_endpoint_public_access  = var.endpoint_public_access

  # IRSA
  enable_irsa        = var.enable_irsa
  config_output_path = "./kubeconfig/"

  # TAGS
  tags = module.eks-label.tags

  # CLUSTER LOGGING
  enabled_cluster_log_types = var.enabled_cluster_log_types

  # CLUSTER ENCRYPTION
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources = [
      "secrets"]
    }
  ]
}
# ---------------------------------------------------------------------------------------------------------------------
# AWS EKS Add-ons (VPC CNI, CoreDNS, KubeProxy )
# ---------------------------------------------------------------------------------------------------------------------
module "aws-eks-addon" {

  count = var.create_eks && var.enable_managed_nodegroups || var.create_eks && var.enable_self_managed_nodegroups ? 1 : 0

  source                = "./modules/aws-eks-addon"
  cluster_name          = module.eks.eks_cluster_id
  enable_vpc_cni_addon  = var.enable_vpc_cni_addon
  vpc_cni_addon_version = var.vpc_cni_addon_version

  enable_coredns_addon  = var.enable_coredns_addon
  coredns_addon_version = var.coredns_addon_version

  enable_kube_proxy_addon  = var.enable_kube_proxy_addon
  kube_proxy_addon_version = var.kube_proxy_addon_version
  tags                     = module.eks-label.tags

  depends_on = [
    module.eks
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKET MODULE - NLB/ALB Access logs
# ---------------------------------------------------------------------------------------------------------------------
module "s3" {
  //  count        = var.create_eks ? 1 : 0
  source         = "./modules/s3"
  s3_bucket_name = "${var.tenant}-${var.environment}-${var.zone}-elb-accesslogs-${data.aws_caller_identity.current.account_id}"
  account_id     = data.aws_caller_identity.current.account_id

}


