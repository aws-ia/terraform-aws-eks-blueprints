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
  description = "EKS Managed node group id"
  value       = aws_eks_node_group.managed_ng[*].id
}

output "manage_ng_iam_role_arn" {
  description = "IAM role ARN for EKS Managed Node Group"
  value       = aws_iam_role.managed_ng[*].arn
}

output "manage_ng_iam_role_name" {
  value = aws_iam_role.managed_ng[*].name
}

output "launch_template_ids" {
  description = "launch templated id for EKS Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].id
}

output "launch_template_arn" {
  description = "launch templated id for EKS Self Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].arn
}

output "launch_template_latest_versions" {
  description = "launch templated version for EKS Managed Node Group"
  value       = aws_launch_template.managed_node_groups[*].default_version
}
