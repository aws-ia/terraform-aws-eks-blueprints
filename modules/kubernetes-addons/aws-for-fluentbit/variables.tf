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

variable "helm_config" {
  type        = any
  description = "Helm provider config aws_for_fluent_bit."
  default     = {}
}

variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster Id"
}

variable "cw_log_group_name" {
  type        = string
  description = "FluentBit CloudWatch Log group name"
  default     = null
}

variable "cw_log_group_retention" {
  type        = number
  description = "FluentBit CloudWatch Log group retention period"
  default     = 90
}

variable "cw_log_group_kms_key_arn" {
  type        = string
  description = "FluentBit CloudWatch Log group KMS Key"
  default     = null
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "tags" {
  type        = map(string)
  description = "Common Tags for AWS resources"
}

variable "irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies for a IAM role for service accounts"
  default     = []
}
