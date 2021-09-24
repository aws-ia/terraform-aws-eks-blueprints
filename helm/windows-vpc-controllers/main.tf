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

locals {
  public_image_repo              = var.public_image_repo
  resource_controller_image_repo = var.public_docker_repo ? "${local.public_image_repo}/${var.resource_controller_image_repo_name}" : "${var.private_container_repo_url}/${var.resource_controller_image_repo_name}"
  admission_webhook_image_repo   = var.public_docker_repo ? "${local.public_image_repo}/${var.admission_webhook_image_repo_name}" : "${var.private_container_repo_url}/${var.admission_webhook_image_repo_name}"
}

resource "helm_release" "windows_vpc_controllers" {
  chart     = "${path.module}/chart"
  name      = "windows-vpc-controllers"
  namespace = "kube-system"
  timeout   = "600"

  values = [templatefile("${path.module}/chart/windows-vpc-controllers-values.tpl", {
    resource_controller_image_repo = local.resource_controller_image_repo
    admission_webhook_image_repo   = local.admission_webhook_image_repo
    resource_controller_image_tag  = var.resource_controller_image_tag
    admission_webhook_image_tag    = var.admission_webhook_image_tag
  })]
}
