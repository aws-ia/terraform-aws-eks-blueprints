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

variable "private_container_repo_url" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "ekslog_retention_in_days" {
  type = number
}

variable "public_docker_repo" {
  type = string
}

variable "aws_for_fluent_bit_helm_chart_url" {
  type    = string
  default = "https://aws.github.io/eks-charts"
}

variable "aws_for_fluent_bit_helm_chart_name" {
  type    = string
  default = "aws-for-fluent-bit"
}

variable "aws_for_fluent_bit_helm_chart_version" {
  type    = string
  default = "0.1.11"
}

variable "aws_for_fluent_bit_image_repo_name" {
  type    = string
  default = "amazon/aws-for-fluent-bit"
}

variable "aws_for_fluent_bit_image_tag" {
  type    = string
  default = "2.13.0"
}
