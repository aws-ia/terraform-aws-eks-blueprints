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

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = var.cluster_id
  addon_name               = local.eks_addon_vpc_cni_config["addon_name"]
  addon_version            = local.eks_addon_vpc_cni_config["addon_version"]
  resolve_conflicts        = local.eks_addon_vpc_cni_config["resolve_conflicts"]
  service_account_role_arn = local.eks_addon_vpc_cni_config["service_account_role_arn"] == "" ? module.irsa_addon.irsa_iam_role_arn : local.eks_addon_vpc_cni_config["service_account_role_arn"]
  tags = merge(
    var.common_tags, local.eks_addon_vpc_cni_config["tags"],
    { "eks_addon" = "vpc-cni" }
  )

  depends_on = [module.irsa_addon]
}

module "irsa_addon" {
  source                     = "../../irsa"
  eks_cluster_name           = var.cluster_id
  create_namespace           = false
  kubernetes_namespace       = local.eks_addon_vpc_cni_config["namespace"]
  kubernetes_service_account = local.eks_addon_vpc_cni_config["service_account"]
  irsa_iam_policies          = concat(["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"], local.eks_addon_vpc_cni_config["additional_iam_policies"])
  tags                       = var.common_tags
}
