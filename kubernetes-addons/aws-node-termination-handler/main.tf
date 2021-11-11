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
