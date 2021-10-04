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

  private_subnet_tags = merge(
    tomap({ "kubernetes.io/role/internal-elb" = "1" }),
    tomap({ "created-by" = var.terraform_version }),
    tomap({ "kubernetes.io/cluster/${module.eks_tags.id}" = "shared" })
  )

  public_subnet_tags = merge(
    tomap({ "kubernetes.io/role/elb" = "1" }),
    tomap({ "created-by" = var.terraform_version }),
    tomap({ "kubernetes.io/cluster/${module.eks_tags.id}" = "shared" })
  )

  ecr_image_repo_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com"

  # Managed node IAM Roles for aws-auth
  managed_node_group_aws_auth_config_map = var.enable_managed_nodegroups == true ? [
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
  self_managed_node_group_aws_auth_config_map = var.enable_self_managed_nodegroups ? [
    for key, node in var.self_managed_node_groups : {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}"
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    } if node.custom_ami_type != "windows"
  ] : []

  # Self Managed Windows node IAM Roles for aws-auth
  windows_node_group_aws_auth_config_map = var.enable_self_managed_nodegroups && var.enable_windows_support ? [
    for key, node in var.self_managed_node_groups : {
      rolearn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}"
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        "eks:kube-proxy-windows"
      ]
    } if node.custom_ami_type == "windows"
  ] : []

  # Fargate node IAM Roles for aws-auth
  fargate_profiles_aws_auth_config_map = var.enable_fargate == true ? [
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

}