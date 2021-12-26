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

resource "aws_prometheus_workspace" "amp_workspace" {
  alias = local.amazon_prometheus_workspace_alias
}

module "irsa" {
  for_each = local.irsa_config

  source                     = "../irsa"
  eks_cluster_id             = var.eks_cluster_id
  kubernetes_namespace       = var.namespace
  create_kubernetes_namespace = each.value["create_kubernetes_namespace"]
  kubernetes_service_account = each.value["service_account"]
  irsa_iam_policies          = each.value["irsa_iam_policies"]
  tags                       = var.tags
}

resource "aws_iam_policy" "ingest" {
  name = format("%s-%s", "amp-ingest", var.eks_cluster_id)
  description = "Set up the permission policy that grants ingest (remote write) permissions for AMP workspace"
  path = var.iam_role_path
  policy = data.aws_iam_policy_document.ingest.json
}

resource "aws_iam_policy" "query" {
  name = format("%s-%s", "amp-query", var.eks_cluster_id)
  description = "Set up the permission policy that grants query permissions for AMP workspace"
  path = var.iam_role_path
  policy = data.aws_iam_policy_document.query.json
}
