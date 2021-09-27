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

variable "agones_image_repo" {
  type    = string
  default = "gcr.io/agones-images"
}

variable "agones_image_tag" {
  type    = string
  default = "1.15.0"
}

variable "agones_helm_chart_name" {
  type    = string
  default = "agones"
}

variable "agones_helm_chart_url" {
  type    = string
  default = "https://agones.dev/chart/stable"
}

variable "agones_game_server_maxport" {
  type    = number
  default = 8000
}
variable "agones_game_server_minport" {
  type    = number
  default = 7000
}

variable "cluster_id" {
  type = string
}

variable "eks_sg_id" {
  type = string
}

variable "public_docker_repo" {
  type = string
}

variable "s3_nlb_logs" {
  type = string
}

variable "expose_udp" {
  type    = bool
  default = false
}
