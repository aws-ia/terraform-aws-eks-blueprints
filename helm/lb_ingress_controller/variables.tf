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

variable "public_docker_repo" {}
variable "private_container_repo_url" {}
variable "image_repo_name" {
  default = "amazon/aws-load-balancer-controller"
}

variable "public_image_repo" {
  default = "602401143452.dkr.ecr.us-west-2.amazonaws.com"
}
variable "aws_lb_image_tag" {
  default = "v2.2.1"
}
variable "aws_lb_helm_chart_version" {
  default = "1.2.3"
}

variable "replicas" {
  default = "2"
}

variable "clusterName" {}

variable "eks_oidc_provider_arn" {}

variable "eks_oidc_issuer_url" {}