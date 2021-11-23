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

resource "aws_sqs_queue_policy" "aws_node_termination_handler_queue_policy" {
  queue_url = aws_sqs_queue.aws_node_termination_handler_queue.id

  policy = local.queue_policy
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

module "irsa" {
  source                     = "../irsa"
  eks_cluster_name           = var.eks_cluster_name
  kubernetes_namespace       = local.namespace
  create_namespace           = true
  kubernetes_service_account = local.service_account_name
  irsa_iam_policies          = [aws_iam_policy.aws_node_termination_handler_irsa.arn]
}

resource "aws_iam_policy" "aws_node_termination_handler_irsa" {
  description = "IAM role policy for AWS Node Termination Handler"
  name        = "${var.eks_cluster_name}-aws-nth-irsa"
  policy      = local.irsa_policy
}

resource "helm_release" "aws_node_termination_handler" {
  name       = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  version    = "0.16.0"
  namespace  = local.namespace
  verify     = false
  timeout    = "1200"

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }
  set {
    name  = "serviceAccount.name"
    value = local.service_account_name
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "enableSqsTerminationDraining"
    value = true
  }
  set {
    name  = "queueURL"
    value = aws_sqs_queue.aws_node_termination_handler_queue.url
  }
  set {
    name  = "enablePrometheusServer"
    value = true
  }
}
