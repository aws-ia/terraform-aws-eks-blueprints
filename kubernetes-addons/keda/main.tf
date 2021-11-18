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

data "aws_caller_identity" "current" {}

resource "helm_release" "keda" {
  count                      = var.manage_via_gitops ? 0 : 1
  name                       = local.keda_helm_app["name"]
  repository                 = local.keda_helm_app["repository"]
  chart                      = local.keda_helm_app["chart"]
  version                    = local.keda_helm_app["version"]
  timeout                    = local.keda_helm_app["timeout"]
  values                     = local.keda_helm_app["values"]
  create_namespace           = var.keda_create_irsa ? false : local.keda_helm_app["create_namespace"]
  namespace                  = var.keda_create_irsa ? module.irsa[0].kubernetes_namespace_id : local.keda_helm_app["namespace"]
  lint                       = local.keda_helm_app["lint"]
  description                = local.keda_helm_app["description"]
  repository_key_file        = local.keda_helm_app["repository_key_file"]
  repository_cert_file       = local.keda_helm_app["repository_cert_file"]
  repository_ca_file         = local.keda_helm_app["repository_ca_file"]
  repository_username        = local.keda_helm_app["repository_username"]
  repository_password        = local.keda_helm_app["repository_password"]
  verify                     = local.keda_helm_app["verify"]
  keyring                    = local.keda_helm_app["keyring"]
  disable_webhooks           = local.keda_helm_app["disable_webhooks"]
  reuse_values               = local.keda_helm_app["reuse_values"]
  reset_values               = local.keda_helm_app["reset_values"]
  force_update               = local.keda_helm_app["force_update"]
  recreate_pods              = local.keda_helm_app["recreate_pods"]
  cleanup_on_fail            = local.keda_helm_app["cleanup_on_fail"]
  max_history                = local.keda_helm_app["max_history"]
  atomic                     = local.keda_helm_app["atomic"]
  skip_crds                  = local.keda_helm_app["skip_crds"]
  render_subchart_notes      = local.keda_helm_app["render_subchart_notes"]
  disable_openapi_validation = local.keda_helm_app["disable_openapi_validation"]
  wait                       = local.keda_helm_app["wait"]
  wait_for_jobs              = local.keda_helm_app["wait_for_jobs"]
  dependency_update          = local.keda_helm_app["dependency_update"]
  replace                    = local.keda_helm_app["replace"]

  postrender {
    binary_path = local.keda_helm_app["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = var.keda_create_irsa ? distinct(concat(local.irsa_set_values, local.keda_helm_app["set"])) : local.keda_helm_app["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.keda_helm_app["set_sensitive"] == null ? [] : local.keda_helm_app["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  depends_on = [module.irsa]
}

module "irsa" {
  count = var.keda_create_irsa ? 1 : 0

  source                     = "../irsa"
  eks_cluster_name           = var.eks_cluster_name
  kubernetes_namespace       = local.keda_namespace
  kubernetes_service_account = local.keda_service_account_name
  irsa_iam_policies          = concat([aws_iam_policy.keda_irsa[0].arn], var.keda_irsa_policies)
  tags                       = var.tags
}

resource "aws_iam_policy" "keda_irsa" {
  count = var.keda_create_irsa ? 1 : 0

  description = "KEDA IAM role policy for SQS and CloudWatch"
  name        = "${var.eks_cluster_name}-${local.keda_helm_app["name"]}-irsa"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.keda_irsa.json
}

data "aws_iam_policy_document" "keda_irsa" {
  statement {
    effect = "Allow"

    resources = [
      "arn:aws:cloudwatch:*:${data.aws_caller_identity.current.account_id}:metric-stream/*",
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:*",
    ]

    actions = [
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
      "sqs:ListQueueTags",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:GetDashboard",
      "cloudwatch:GetInsightRuleReport",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetMetricStream",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudwatch:DescribeInsightRules",
      "sqs:ListQueues",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetricStreams",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:ListDashboards",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricWidgetImage",
      "cloudwatch:ListMetrics",
      "cloudwatch:DescribeAnomalyDetectors",
    ]
  }
}
