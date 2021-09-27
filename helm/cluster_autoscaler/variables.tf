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

variable "cluster_autoscaler_helm_repo_url" {
  type    = string
  default = "https://kubernetes.github.io/autoscaler"
}

variable "cluster_autoscaler_helm_chart_name" {
  type    = string
  default = "cluster-autoscaler"
}
variable "private_container_repo_url" {
  type = string
}

variable "cluster_autoscaler_image_repo_name" {
  type    = string
  default = "k8s.gcr.io/autoscaling/cluster-autoscaler"
}
variable "cluster_autoscaler_image_tag" {
  type    = string
  default = "v1.21.0"
}

variable "cluster_autoscaler_helm_version" {
  type    = string
  default = "9.10.7"
}
variable "eks_cluster_id" {
  type        = string
  description = "EKS_Cluster_ID"
}

variable "public_docker_repo" {
  type = bool
}