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

locals {
  default_addon_config = {
    namespace                        = "aws-otel-eks"
    emitter_otel_resource_attributes = "service.namespace=AWSObservability,service.name=ADOTEmitService"
    emitter_name                     = "trace-emitter"
    emitter_image                    = "public.ecr.aws/g9c4k4i4/trace-emitter:1"
    collector_image                  = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
    aws_region                       = "eu-west-1"
    emitter_oltp_endpoint            = "localhost:55680"
    mg_node_iam_role_arns            = []
    elf_mg_node_iam_role_arns        = []
  }

  addon_config = merge(
    local.default_addon_config,
    var.addon_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
