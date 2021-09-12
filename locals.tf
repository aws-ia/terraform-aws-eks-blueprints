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

  tags                = tomap({ "created-by" = var.terraform_version })
  private_subnet_tags = merge(tomap({ "kubernetes.io/role/internal-elb" = "1" }), tomap({ "created-by" = var.terraform_version }))
  public_subnet_tags  = merge(tomap({ "kubernetes.io/role/elb" = "1" }), tomap({ "created-by" = var.terraform_version }))

  service_account_amp_ingest_name = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "amp-ingest-account")
  service_account_amp_query_name  = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "amp-query-account")
  amp_workspace_name              = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "EKS-Metrics-Workspace")

  image_repo = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/"

  self_managed_node_platform = var.enable_windows_support ? "windows" : "linux"

  //  rbac_roles = [
  //    {
  //      rolearn = module.iam.eks_rbac_admin_arn
  //      username = "admin"
  //      groups = [
  //        "system:masters"]
  //    },
  //    {
  //      rolearn = module.iam.eks_rbac_devs_arn
  //      username = "devs"
  //      groups = [
  //        "default:developers"]
  //    }
  //  ]
  //
  //
  //  yaml_quote = var.aws_auth_yaml_strip_quotes ? "" : "\""
  //
  # Managed node IAM Roles for aws-auth
  //  managed_map_worker_roles = [
  //    for role_arn in var.managed_node_groups["node_group_name"] : {
  //      rolearn : role_arn
  //      username : "system:node:{{EC2PrivateDNSName}}"
  //      groups : [
  //        "system:bootstrappers",
  //        "system:nodes"
  //      ]
  //    }
  //  ]
  //
  //  # Self managed node IAM Roles for aws-auth
  //  self_managed_map_worker_roles = [
  //  for role_arn in module.managed-node-groups.mg_linux_roles : {
  //    rolearn : role_arn
  //    username : "system:node:{{EC2PrivateDNSName}}"
  //    groups : [
  //      "system:bootstrappers",
  //      "system:nodes"
  //    ]
  //  }
  //  ]

}