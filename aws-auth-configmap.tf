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

resource "kubernetes_config_map" "aws_auth" {
  count = var.create_eks ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    labels = merge(
      {
        "app.kubernetes.io/managed-by" = "Terraform"
        "terraform.io/module"          = "terraform-ssp-amazon-eks"
      },
      var.aws_auth_additional_labels
    )
  }

  data = {
    mapRoles = yamlencode(
      distinct(concat(
        local.managed_node_group_aws_auth_config_map,
        local.self_managed_node_group_aws_auth_config_map,
        local.windows_node_group_aws_auth_config_map,
        local.fargate_profiles_aws_auth_config_map,
        local.emr_on_eks_config_map,
        local.application_teams_config_map,
        local.platform_teams_config_map,
        var.map_roles,
      ))
    )
    mapUsers    = yamlencode(var.map_users)
    mapAccounts = yamlencode(var.map_accounts)
  }

  depends_on = [module.aws_eks.cluster_id, data.http.eks_cluster_readiness[0]]
}
