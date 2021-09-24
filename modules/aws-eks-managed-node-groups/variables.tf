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

variable "enable_managed_nodegroups" {
  description = "Enable Managed worker groups"
  type        = bool
  default     = false
}

variable "managed_ng" {
  description = "Map of maps of `eks_node_groups` to create"
  type        = any
  default     = {}
}

variable "eks_cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "cluster_ca_base64" {
  description = "Base64-encoded EKS cluster certificate-authority-data"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS Cluster K8s API server endpoint"
  type        = string
}

variable "cluster_security_group_id" {
  type        = string
  description = "EKS Cluster Security group ID"
  default     = ""
}

variable "cluster_primary_security_group_id" {
  description = "EKS Cluster primary security group ID"
  type        = string
  default     = ""
}

variable "worker_security_group_id" {
  description = "Worker group security ID"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC Id used in security group creation"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  default     = []
}

variable "public_subnet_ids" {
  description = "list of public subnets Id's for the Worker nodes"
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "path" {
  type        = string
  default     = "/"
  description = "IAM resource path, e.g. /dev/"
}

variable "http_endpoint" {
  type        = string
  default     = "enabled"
  description = "Whether the Instance Metadata Service (IMDS) is available. Supported values: enabled, disabled"
}

variable "http_tokens" {
  type        = string
  default     = "optional"
  description = "If enabled, will use Instance Metadata Service Version 2 (IMDSv2). Supported values: optional, required."
}

variable "http_put_response_hop_limit" {
  type        = number
  default     = 1
  description = "HTTP PUT response hop limit for instance metadata requests. Supported values: 1-64."
}

