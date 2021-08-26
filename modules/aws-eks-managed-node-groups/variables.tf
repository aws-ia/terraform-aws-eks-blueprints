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

variable "eks_cluster_name" {
  type = string
}

variable "cluster_ca_base64" {
  type        = string
  default     = ""
  description = "Base64-encoded cluster certificate-authority-data"
}

variable "cluster_endpoint" {
  type        = string
  default     = ""
  description = "Cluster K8s API server endpoint"
}

variable "create_eks" {
  description = "Controls if EKS resources should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "private_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  default     = []
}

variable "public_subnet_ids" {
  description = "list of public subnets Id's for the Worker nodes"
  default     = []
}

variable "worker_security_group_id" {
  description = "Worker group security ID"
  type        = string
  default     = ""
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable "managed_ng" {
  description = "Map of maps of `eks_node_groups` to create"
  type        = any
  default     = {}
}

variable "use_custom_ami" {
  type        = bool
  default     = false
  description = "Use custom AMI"
}

variable "path" {
  type        = string
  default     = "/"
  description = "IAM resource path, e.g. /dev/"
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
