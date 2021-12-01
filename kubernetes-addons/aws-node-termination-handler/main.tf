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
}

data "aws_iam_policy_document" "aws_node_termination_handler_queue_policy_document" {
  statement {
    actions = [
      "sqs:SendMessage"
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com"
      ]
    }
    resources = [
      aws_sqs_queue.aws_node_termination_handler_queue.arn
    ]
  }
}
resource "aws_sqs_queue_policy" "aws_node_termination_handler_queue_policy" {
  queue_url = aws_sqs_queue.aws_node_termination_handler_queue.id

  policy = data.aws_iam_policy_document.aws_node_termination_handler_queue_policy_document.json
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

data "aws_iam_policy_document" "irsa_policy" {
  statement {
    actions = [
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstances",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws_node_termination_handler_irsa" {
  description = "IAM role policy for AWS Node Termination Handler"
  name        = "${var.eks_cluster_name}-aws-nth-irsa"
  policy      = data.aws_iam_policy_document.irsa_policy.json
}

module "irsa" {
  source                     = "../irsa"
  eks_cluster_name           = var.eks_cluster_name
  kubernetes_namespace       = local.namespace
  create_namespace           = false
  kubernetes_service_account = local.service_account_name
  irsa_iam_policies          = [aws_iam_policy.aws_node_termination_handler_irsa.arn]
}

resource "helm_release" "aws_node_termination_handler" {
  name                       = local.aws_node_termination_handler_helm_app["name"]
  repository                 = local.aws_node_termination_handler_helm_app["repository"]
  chart                      = local.aws_node_termination_handler_helm_app["chart"]
  version                    = local.aws_node_termination_handler_helm_app["version"]
  namespace                  = local.aws_node_termination_handler_helm_app["namespace"]
  timeout                    = local.aws_node_termination_handler_helm_app["timeout"]
  values                     = local.aws_node_termination_handler_helm_app["values"]
  create_namespace           = local.aws_node_termination_handler_helm_app["create_namespace"]
  lint                       = local.aws_node_termination_handler_helm_app["lint"]
  description                = local.aws_node_termination_handler_helm_app["description"]
  repository_key_file        = local.aws_node_termination_handler_helm_app["repository_key_file"]
  repository_cert_file       = local.aws_node_termination_handler_helm_app["repository_cert_file"]
  repository_ca_file         = local.aws_node_termination_handler_helm_app["repository_ca_file"]
  repository_username        = local.aws_node_termination_handler_helm_app["repository_username"]
  repository_password        = local.aws_node_termination_handler_helm_app["repository_password"]
  verify                     = local.aws_node_termination_handler_helm_app["verify"]
  keyring                    = local.aws_node_termination_handler_helm_app["keyring"]
  disable_webhooks           = local.aws_node_termination_handler_helm_app["disable_webhooks"]
  reuse_values               = local.aws_node_termination_handler_helm_app["reuse_values"]
  reset_values               = local.aws_node_termination_handler_helm_app["reset_values"]
  force_update               = local.aws_node_termination_handler_helm_app["force_update"]
  recreate_pods              = local.aws_node_termination_handler_helm_app["recreate_pods"]
  cleanup_on_fail            = local.aws_node_termination_handler_helm_app["cleanup_on_fail"]
  max_history                = local.aws_node_termination_handler_helm_app["max_history"]
  atomic                     = local.aws_node_termination_handler_helm_app["atomic"]
  skip_crds                  = local.aws_node_termination_handler_helm_app["skip_crds"]
  render_subchart_notes      = local.aws_node_termination_handler_helm_app["render_subchart_notes"]
  disable_openapi_validation = local.aws_node_termination_handler_helm_app["disable_openapi_validation"]
  wait                       = local.aws_node_termination_handler_helm_app["wait"]
  wait_for_jobs              = local.aws_node_termination_handler_helm_app["wait_for_jobs"]
  dependency_update          = local.aws_node_termination_handler_helm_app["dependency_update"]
  replace                    = local.aws_node_termination_handler_helm_app["replace"]

  postrender {
    binary_path = local.aws_node_termination_handler_helm_app["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = local.aws_node_termination_handler_helm_app["set"] == null ? [] : local.aws_node_termination_handler_helm_app["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.aws_node_termination_handler_helm_app["set_sensitive"] == null ? [] : local.aws_node_termination_handler_helm_app["set_sensitive"]

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
