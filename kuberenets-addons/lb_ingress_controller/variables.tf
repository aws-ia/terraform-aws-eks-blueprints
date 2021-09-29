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

variable "aws_lb_helm_repo_url" {
  type    = string
  default = "https://aws.github.io/eks-charts"
}

variable "aws_lb_helm_helm_chart_name" {
  type    = string
  default = "aws-load-balancer-controller"
}
variable "public_docker_repo" {
  type = bool
}

variable "private_container_repo_url" {
  type = string
}

variable "aws_lb_image_repo_name" {
  type    = string
  default = "amazon/aws-load-balancer-controller"
}

variable "public_image_repo" {
  type    = string
  default = "602401143452.dkr.ecr.us-west-2.amazonaws.com"
}
variable "aws_lb_image_tag" {
  type    = string
  default = "v2.2.4"
}
variable "aws_lb_helm_chart_version" {
  type    = string
  default = "1.2.7"
}

variable "replicas" {
  type    = string
  default = "2"
}

variable "clusterName" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type = string
}

variable "eks_oidc_issuer_url" {
  type = string
}