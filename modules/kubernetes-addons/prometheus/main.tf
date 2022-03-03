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

resource "helm_release" "prometheus" {
  count                      = var.manage_via_gitops ? 0 : 1
  name                       = local.helm_config["name"]
  repository                 = local.helm_config["repository"]
  chart                      = local.helm_config["chart"]
  version                    = local.helm_config["version"]
  namespace                  = local.helm_config["namespace"]
  timeout                    = local.helm_config["timeout"]
  create_namespace           = local.helm_config["create_namespace"]
  lint                       = local.helm_config["lint"]
  description                = local.helm_config["description"]
  repository_key_file        = local.helm_config["repository_key_file"]
  repository_cert_file       = local.helm_config["repository_cert_file"]
  repository_ca_file         = local.helm_config["repository_ca_file"]
  repository_username        = local.helm_config["repository_username"]
  repository_password        = local.helm_config["repository_password"]
  verify                     = local.helm_config["verify"]
  keyring                    = local.helm_config["keyring"]
  disable_webhooks           = local.helm_config["disable_webhooks"]
  reuse_values               = local.helm_config["reuse_values"]
  reset_values               = local.helm_config["reset_values"]
  force_update               = local.helm_config["force_update"]
  recreate_pods              = local.helm_config["recreate_pods"]
  cleanup_on_fail            = local.helm_config["cleanup_on_fail"]
  max_history                = local.helm_config["max_history"]
  atomic                     = local.helm_config["atomic"]
  skip_crds                  = local.helm_config["skip_crds"]
  render_subchart_notes      = local.helm_config["render_subchart_notes"]
  disable_openapi_validation = local.helm_config["disable_openapi_validation"]
  wait                       = local.helm_config["wait"]
  wait_for_jobs              = local.helm_config["wait_for_jobs"]
  dependency_update          = local.helm_config["dependency_update"]
  replace                    = local.helm_config["replace"]
  values                     = local.helm_config["values"]

  postrender {
    binary_path = local.helm_config["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = var.amazon_prometheus_workspace_endpoint != null ? distinct(concat(local.amp_config_values, local.helm_config["set"])) : local.helm_config["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.helm_config["set_sensitive"] == null ? [] : local.helm_config["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

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
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = false
  kubernetes_service_account  = local.amazon_prometheus_ingest_service_account
  irsa_iam_policies           = [aws_iam_policy.ingest[0].arn]
  addon_context               = var.addon_context

  depends_on = [kubernetes_namespace_v1.prometheus]
}

module "irsa_amp_query" {
  count                       = var.enable_amazon_prometheus ? 1 : 0
  source                      = "../../../modules/irsa"
  kubernetes_namespace        = local.helm_config["namespace"]
  create_kubernetes_namespace = false
  kubernetes_service_account  = "amp-query"
  irsa_iam_policies           = [aws_iam_policy.query[0].arn]
  addon_context               = var.addon_context

  depends_on = [kubernetes_namespace_v1.prometheus]
}

resource "aws_iam_policy" "ingest" {
  count       = var.enable_amazon_prometheus ? 1 : 0
  name        = format("%s-%s", "amp-ingest", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants ingest (remote write) permissions for AMP workspace"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.ingest.json
  tags        = var.addon_context.tags
}

resource "aws_iam_policy" "query" {
  count       = var.enable_amazon_prometheus ? 1 : 0
  name        = format("%s-%s", "amp-query", var.addon_context.eks_cluster_id)
  description = "Set up the permission policy that grants query permissions for AMP workspace"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.query.json
  tags        = var.addon_context.tags
}
