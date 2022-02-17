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

data "template_file" "amp_values" {
  template = "${file("${path.module}/values.yaml")}"
  vars = {
    amazon_promtheus_remote_write_url = var.amazon_promtheus_remote_write_url
    region = data.aws_region.current.name
  }
}

resource "helm_release" "prometheus" {
  count                      = var.manage_via_gitops ? 0 : 1

  values = [
    data.template_file.amp_values.rendered
  ]

  depends_on = [kubernetes_namespace_v1.prometheus]
}



resource "kubernetes_namespace_v1" "prometheus" {
  metadata {
    name = local.helm_config["namespace"]
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    }
  }
}

module "irsa_amp_ingest" {
  count                       = var.enable_amazon_prometheus ? 1 : 0
  source                      = "../../../modules/irsa"
  eks_cluster_id              = var.eks_cluster_id
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = false
  kubernetes_service_account  = local.amazon_prometheus_ingest_service_account
  irsa_iam_policies           = [aws_iam_policy.ingest[0].arn]
  tags                        = var.tags

  depends_on = [kubernetes_namespace_v1.prometheus]
}

module "irsa_amp_query" {
  count                       = var.enable_amazon_prometheus ? 1 : 0
  source                      = "../../../modules/irsa"
  eks_cluster_id              = var.eks_cluster_id
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = false
  kubernetes_service_account  = "amp-query"
  irsa_iam_policies           = [aws_iam_policy.query[0].arn]
  tags                        = var.tags

  depends_on = [kubernetes_namespace_v1.prometheus]
}

resource "aws_iam_policy" "ingest" {
  count       = var.enable_amazon_prometheus ? 1 : 0
  name        = format("%s-%s", "amp-ingest", var.eks_cluster_id)
  description = "Set up the permission policy that grants ingest (remote write) permissions for AMP workspace"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.ingest.json
  tags        = var.tags
}

resource "aws_iam_policy" "query" {
  count       = var.enable_amazon_prometheus ? 1 : 0
  name        = format("%s-%s", "amp-query", var.eks_cluster_id)
  description = "Set up the permission policy that grants query permissions for AMP workspace"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.query.json
  tags        = var.tags
}
