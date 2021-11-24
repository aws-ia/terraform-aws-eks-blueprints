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

variable "kubernetes_namespace" {
  description = "Kubernetes Namespace name"
}

variable "create_namespace" {
  description = "Should the module create the namespace"
  type        = bool
  default     = true
}
variable "kubernetes_service_account" {
  description = "Kubernetes Service Account Name"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS Cluster Id"
}

variable "iam_role_path" {
  type        = string
  default     = "/"
  description = "IAM Role path"
}

variable "tags" {
  type        = map(string)
  description = "Common tags for AWS resources"
  default     = null
}

variable "irsa_iam_policies" {
  type        = list(string)
  description = "IAM Policies for IRSA IAM role"
}
