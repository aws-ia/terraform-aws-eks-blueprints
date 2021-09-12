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

module "aws-eks-self-managed-node-groups" {
  for_each = length(var.self_managed_node_groups) > 0 && var.enable_self_managed_nodegroups ? var.self_managed_node_groups : {}

  source          = "./modules/aws-eks-self-managed-node-groups"
  self_managed_ng = each.value

  eks_cluster_name  = module.eks.cluster_id
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca_base64 = module.eks.cluster_certificate_authority_data
  cluster_version   = var.kubernetes_version
  tags              = module.eks-label.tags


  vpc_id             = var.create_vpc == false ? var.vpc_id : module.vpc.vpc_id
  private_subnet_ids = var.create_vpc == false ? var.private_subnet_ids : module.vpc.private_subnets
  public_subnet_ids  = var.create_vpc == false ? var.public_subnet_ids : module.vpc.public_subnets

  default_worker_security_group_id  = module.eks.worker_security_group_id
  cluster_primary_security_group_id = module.eks.cluster_security_group_id

  depends_on = [module.eks, kubernetes_config_map.aws_auth]

}