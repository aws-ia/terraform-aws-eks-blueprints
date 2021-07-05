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

variable "image_repo_url" {}

variable "metrics_server_enable" {
  type        = bool
  default     = true
  description = "Enabling metrics server on eks cluster"
}
variable "cluster_autoscaler_enable" {
  type        = bool
  default     = true
  description = "Enabling cluster autoscaler server on eks cluster"
}
variable "traefik_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling Traefik Ingress on eks cluster"
}

variable "lb_ingress_controller_enable" {
  type        = bool
  default     = false
  description = "Enabling LB Ingress controller on eks cluster"
}

variable "aws_for_fluent_bit_enable" {
  type        = bool
  default     = false
  description = "Enabling aws_fluent_bit on eks cluster"
}

variable "fargate_fluent_bit_enable" {
  type        = bool
  default     = false
  description = "Enabling fargate_fluent_bit on eks cluster"
}

variable "fargate_iam_role" {}

variable "s3_nlb_logs" {
  description = "S3 bucket for NLB Logs"
}

variable "eks_cluster_id" {
  description = "EKS cluster Id"
}

variable "ekslog_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days."
}

variable "public_docker_repo" {}

variable "eks_oidc_issuer_url" {}

variable "eks_oidc_provider_arn" {}

variable "expose_udp" {}

variable "agones_enable" {
  type        = bool
  default     = false
  description = "Enabling agones on eks cluster"
}

variable "eks_security_group_id" {}