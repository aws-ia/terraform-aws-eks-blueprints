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

resource "aws_sqs_queue_policy" "test" {
  queue_url = aws_sqs_queue.aws_node_termination_handler_queue.id

  policy = jsonencode({
    Version : "2012-10-17"
    Id : "MyQueuePolicy"
    Statement : [{
      Effect : "Allow"
      Principal : {
        Service : ["events.amazonaws.com", "sqs.amazonaws.com"]
      }
      Action : "sqs:SendMessage"
      Resource : [
        aws_sqs_queue.aws_node_termination_handler_queue.arn
      ]
    }]
  })
}

locals {
  rules = [
    {
      name          = "ASGTermRule",
      event_pattern = <<EOF
{"source":["aws.autoscaling"],"detail-type":["EC2 Instance-terminate Lifecycle Action"]}
EOF
    },
    {
      name          = "SpotTermRule",
      event_pattern = <<EOF
{"source": ["aws.ec2"],"detail-type": ["EC2 Spot Instance Interruption Warning"]}
EOF
    },
    {
      name = "RebalanceRule",
      event_pattern = <<EOF
{"source": ["aws.ec2"],"detail-type": ["EC2 Instance Rebalance Recommendation"]}
EOF
    },
    {
      name = "InstanceStateChangeRule",
      event_pattern = <<EOF
{"source": ["aws.ec2"],"detail-type": ["EC2 Instance State-change Notification"]}
EOF
    },
    {
      name = "ScheduledChangeRule",
      event_pattern = <<EOF
{"source": ["aws.health"],"detail-type": ["AWS Health Event"]}
EOF
    }
  ]
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler_rule" {
  count = length(local.rules)

  name          = local.rules[count.index].name
  event_pattern = local.rules[count.index].event_pattern
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler_rule_target" {
  count = length(aws_cloudwatch_event_rule.aws_node_termination_handler_rule)

  rule = aws_cloudwatch_event_rule.aws_node_termination_handler_rule[count.index].id
  arn  = aws_sqs_queue.aws_node_termination_handler_queue.arn
}

resource "helm_release" "aws_node_termination_handler" {
  name        = local.aws_node_termination_handler_helm_app["name"]
  repository  = local.aws_node_termination_handler_helm_app["repository"]
  chart       = local.aws_node_termination_handler_helm_app["chart"]
  version     = local.aws_node_termination_handler_helm_app["version"]
  namespace   = local.aws_node_termination_handler_helm_app["namespace"]
  timeout     = local.aws_node_termination_handler_helm_app["timeout"]
  values      = local.aws_node_termination_handler_helm_app["values"]
  description = local.aws_node_termination_handler_helm_app["description"]
  verify      = local.aws_node_termination_handler_helm_app["verify"]
}
