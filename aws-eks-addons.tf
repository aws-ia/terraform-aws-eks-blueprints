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

module "vpc_cni" {
  count         = var.create_eks && var.enable_eks_addon_vpc_cni ? 1 : 0
  source        = "./modules/aws-eks-addon/vpc-cni"
  add_on_config = var.eks_addon_vpc_cni_config
  cluster_id    = module.aws_eks.cluster_id
  common_tags   = var.tags

  depends_on = [module.aws_eks]
}

module "coredns" {
  count         = var.create_eks && var.enable_eks_addon_coredns ? 1 : 0
  source        = "./modules/aws-eks-addon/coredns"
  add_on_config = var.eks_addon_coredns_config
  cluster_id    = module.aws_eks.cluster_id
  common_tags   = var.tags

  depends_on = [module.aws_eks]
}

module "kube_proxy" {
  count         = var.create_eks && var.enable_eks_addon_kube_proxy ? 1 : 0
  source        = "./modules/aws-eks-addon/kube-proxy"
  add_on_config = var.eks_addon_kube_proxy_config
  cluster_id    = module.aws_eks.cluster_id
  common_tags   = var.tags

  depends_on = [module.aws_eks]
}

module "aws_ebs_csi_driver" {
  count         = var.create_eks && var.enable_eks_addon_aws_ebs_csi_driver ? 1 : 0
  source        = "./modules/aws-eks-addon/aws-ebs-csi-driver"
  add_on_config = var.eks_addon_aws_ebs_csi_driver_config
  cluster_id    = module.aws_eks.cluster_id
  common_tags   = var.tags

  depends_on = [module.aws_eks]
}
