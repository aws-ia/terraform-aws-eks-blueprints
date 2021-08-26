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

output "node_groups" {
  description = "Outputs from EKS node groups "
  value       = coalescelist(aws_eks_node_group.managed_ng.*.id, [""])[0]
  //  value       = [for f in aws_eks_node_group.managed_ng : f.id]
  //join("", aws_iam_role.default.*.arn)
}

output "mg_linux_roles" {
  description = "Linux node IAM role"
  value       = coalescelist(aws_iam_role.mg_linux[*].arn, [""])[0]
}

output "launch_template_ids" {
  value = aws_launch_template.managed_node_groups.*.id
  //  value = [for f in aws_launch_template.managed_node_groups : f.id]
}

output "launch_template_latest_versions" {
  value = aws_launch_template.managed_node_groups.*.default_version
  //  value = [for f in aws_launch_template.managed_node_groups : f.id]
}
