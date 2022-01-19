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

resource "helm_release" "aws_node_termination_handler" {
  name                       = local.helm_config["name"]
  repository                 = local.helm_config["repository"]
  chart                      = local.helm_config["chart"]
  version                    = local.helm_config["version"]
  namespace                  = local.helm_config["namespace"]
  timeout                    = local.helm_config["timeout"]
  values                     = local.helm_config["values"]
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

  postrender {
    binary_path = local.helm_config["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = local.helm_config["set"] == null ? [] : local.helm_config["set"]

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
  set {
    name  = "queueURL"
    value = aws_sqs_queue.aws_node_termination_handler_queue.url
  }

  depends_on = [module.irsa]
}

resource "aws_autoscaling_lifecycle_hook" "aws_node_termination_handler_hook" {
  count = length(var.autoscaling_group_names)

  name                   = "aws_node_termination_handler_hook"
  autoscaling_group_name = var.autoscaling_group_names[count.index]
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}

resource "aws_autoscaling_group_tag" "aws_node_termination_handler_tag" {
  count = length(var.autoscaling_group_names)

  autoscaling_group_name = var.autoscaling_group_names[count.index]

  tag {
    key   = "aws-node-termination-handler/managed"
    value = "true"

    propagate_at_launch = true
  }
}

resource "aws_sqs_queue" "aws_node_termination_handler_queue" {
  name_prefix               = "aws_node_termination_handler"
  message_retention_seconds = "300"
  sqs_managed_sse_enabled   = true
  tags                      = var.tags
}

resource "aws_sqs_queue_policy" "aws_node_termination_handler_queue_policy" {
  queue_url = aws_sqs_queue.aws_node_termination_handler_queue.id
  policy    = data.aws_iam_policy_document.aws_node_termination_handler_queue_policy_document.json
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler_rule" {
  count = length(local.event_rules)

  name          = local.event_rules[count.index].name
  event_pattern = local.event_rules[count.index].event_pattern
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler_rule_target" {
  count = length(aws_cloudwatch_event_rule.aws_node_termination_handler_rule)

  rule = aws_cloudwatch_event_rule.aws_node_termination_handler_rule[count.index].id
  arn  = aws_sqs_queue.aws_node_termination_handler_queue.arn
}

resource "aws_iam_policy" "aws_node_termination_handler_irsa" {
  description = "IAM role policy for AWS Node Termination Handler"
  name        = "${var.eks_cluster_id}-aws-nth-irsa"
  policy      = data.aws_iam_policy_document.irsa_policy.json
  tags        = var.tags
}

module "irsa" {
  source                      = "../../../modules/irsa"
  eks_cluster_id              = var.eks_cluster_id
  kubernetes_namespace        = local.namespace
  create_kubernetes_namespace = false
  kubernetes_service_account  = local.service_account_name
  irsa_iam_policies           = [aws_iam_policy.aws_node_termination_handler_irsa.arn]
}
