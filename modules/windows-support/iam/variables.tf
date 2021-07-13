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

variable "cluster_name" {
  type        = string
  description = "Cluster name"
}
variable "path" {
  type        = string
  default     = "/"
  description = "IAM resource path, e.g. /dev/"
}
variable "tags" {
  type        = map(any)
  description = "Tags for the IAM resources"
}
variable "autoscaler_policy_arn" {
  type        = string
  description = "Cluster Autoscaler IAM policy ARN"
  default     = null
}
variable "aws_managed_prometheus_enable" {
  type        = bool
  description = "Enable AWS-managed Prometheus"
  default     = false
}
variable "cluster_autoscaler_enable" {
  type        = bool
  description = "Enable AWS-managed Prometheus"
  default     = false
}
